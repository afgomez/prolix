namespace :aemet do

  require 'nokogiri'
  require 'open-uri'
  require "mongo_mapper"
  require "#{RAILS_ROOT}/config/initializers/mongodb"
  require 'aemet'
  require 'region'
  require 'city'
  require 'day'
  require 'prediction'
  require 'observation'
  require 'iconv'
  
#    Dir[File.expand_path(File.join(File.dirname(__FILE__),"#{RAILS_ROOT}/app/models/",'**','*.rb'))].each {|f| require f}


  months = ["enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"]

  task :predictions do

    # for each city we download the predictions
    Region.all.each do |region|

      salida = ""

      region.cities.each do |city|
      

        puts " - #{city.name}"

        doc_city = Nokogiri::HTML(open("http://www.aemet.es/es/eltiempo/prediccion/localidades/#{city.aemet_key}"))

        # for each of the 7 predictions...
        7.times do |i|

          #We recover the day of the prediction (creating it if necessary)
          day = city.days.select { |d| d.date == (Date.today + i) }
          day = day[0]
          
          if day.nil?
            day = Day.new :date => (Date.today + i)
            city.days << day
            day.save
            city.save
          end

          #We check if today we already gave a prediction
          prediction = day.predictions.select { |p| p.date == (Date.today) }
          prediction = prediction[0]

          if prediction.nil?
            #we populate the prediction with the data from AEMET
            pop = -1
            temp_min = -1
            temp_max = -1
            doc_city.xpath("//table[@class='tabla_datos']/tbody/tr[th/@abbr='Pro.']/td[#{i+1}]").each do |html|
              pop = html.content.to_f
            end

            doc_city.xpath("//table[@class='tabla_datos']/tbody/tr[th/@abbr='Max.']/td[#{i+1}]").each do |html|
              temp_max = html.content.to_f
            end

            doc_city.xpath("//table[@class='tabla_datos']/tbody/tr[th/@abbr='Min.']/td[#{i+1}]").each do |html|
              temp_min = html.content.to_f
            end

            salida += "\t#{pop}\t#{temp_max}\t#{temp_min}\n "

            #and now we create the prediction, include it and save it
            prediction = Prediction.new
            prediction.date = (Date.today)
            prediction.pop = pop/100
            prediction.min = temp_min
            prediction.max = temp_max

            day.predictions << prediction
            day.save
          end
        end
        puts salida
      end

    end
  end


  task :observations do

    #for each region
    Region.all.each do |region|

      #we download the HTML of the summary
      doc_region = Nokogiri::HTML(open("http://www.aemet.es/es/eltiempo/observacion/ultimosdatos?k=#{region.aemet_key}&datos=det"))

      doc_predictions = []
      4.times.each do |i|
        doc_predictions[i] = Nokogiri::HTML(open("http://www.aemet.es/es/eltiempo/observacion/ultimosdatos?k=#{region.aemet_key}&datos=det&w=H#{i+1}"))
      end

      region.cities.each do |city|

        #we obtain or create this day for the city
        day = city.days.select { |d| d.date == (Date.today - 1) }
        day = day[0]

        if day.nil?
          day = Day.new :date => (Date.today - 1)
          city.days << day
          day.save
          city.save
          puts day.date
        end

        info = doc_region.xpath("//table[@class='tabla_datos']/tbody/tr[th = '#{city.name}']/td")

        puts " - #{city.name}"

        salida =  "#{day.date}\t#{info[2].content.to_f}\t#{info[0].content.to_f}\t#{info[1].content.to_f}\n"

        #we check if we already have a summary prediction
        summary = day.observations.select { |o| o.hour.nil? }
        summary = summary[0]
        if summary.nil?
          #now we save the summary
          summary = Observation.new(
               :max => info[0].content.to_f,
               :min => info[1].content.to_f,
               :pop => info[2].content.to_f)
          day.observations << summary
          summary.save
          day.save

          #and now we compare all the predictions with this last observation
          day.predictions.each do |p| p.evaluate summary end
        end

        #And now we create the day of today
        day = city.days.select { |d| d.date == (Date.today) }
        day = day[0]
        if day.nil?
          day = Day.new :date => (Date.today)
          city.days << day
          city.save
        end

        # and we try to create all the observations
        4.times.each do |i|

          #we check if we already have this information
          observation = day.observations.select { |o| o.hour == (i*6) + 2 }
          observation = observation[0]
          if observation.nil?

            #if we don't we retrieve the HTML for this observation
            doc = doc_predictions[i]
            
            #we check if this prediction is from today
            unless doc.xpath("//*[@class='notas_tabla']").inner_html.index("#{Date.today.day} #{months[Date.today.month-1]} #{Date.today.year}").nil?

              #if it's from today we create it and save it
              info = doc.xpath("//table[@class='tabla_datos']/tbody/tr[th = '#{city.name}']/td")
              salida +=  "#{Date.today} #{(i*6) + 2}:00\t#{info[3].content.to_f}\t#{info[5].content.to_f}\n"

              observation = Observation.new( :hour => (i*6) + 2,
                 :min => info[3].content.to_f,
                 :max=> info[3].content.to_f,
                 :pop => info[5].content.to_f)

              day.observations << observation
              observation.save
              day.save

              # and now we compare all the predictions with this observation
              # day.predictions.each do |p| p.evaluate observation end

            end  
          end

        end
        puts salida
      end
    end
  end

  task :performance do

    # We get or create the AEMET object
    aemet = Aemet.all.select { |d| d.date == (Date.today - 1) }
    aemet = aemet[0]

    if aemet.nil?
      aemet = Aemet.new
      aemet.date = Date.today - 1
      aemet.prediction_tmax_success = 0
      aemet.prediction_tmin_success = 0
      aemet.prediction_pop_success = 0
      
      #for each city we retrieve yesterday's last prediction
      City.all.each do |city|
        unless city.get_day_from_today(-1)[0].nil? or city.get_day_from_today(-1)[0].get_prediction_from_day(0)[0].nil?
          prediction = city.get_day_from_today(-1)[0].get_prediction_from_day(0)[0]
          aemet.prediction_tmax_success = aemet.prediction_tmax_success + prediction.score_max
          aemet.prediction_tmin_success += prediction.score_min
          aemet.prediction_pop_success += prediction.score_pop


          puts "AEMET\t #{aemet.prediction_tmax_success}\t#{aemet.prediction_tmin_success}\t#{aemet.prediction_pop_success}"
          aemet.save

        end

        unless city.days.blank?
          performance = -1
          days_with_predictions = 0
          7.times.each do |i|
            unless city.get_day_from_today(-(i+1))[0].nil? or city.get_day_from_today(-(i+1))[0].get_prediction_from_day(0)[0].nil?
              performance = city.get_day_from_today(-(i+1))[0].get_prediction_from_day(0)[0].score
              days_with_predictions += 1
            end
          end
          city.general_prediction_success = performance/days_with_predictions

        end

        puts "#{city.name}\t#{city.general_prediction_success}"
      end


          aemet.prediction_tmax_success /= City.count
          aemet.prediction_tmin_success /= City.count
          aemet.prediction_pop_success /= City.count
    end
  end

  task :load_regions do

    doc = Nokogiri::HTML(open("http://www.aemet.es/es/eltiempo/observacion/ultimosdatos"))

    doc.xpath("//map[@id='Map']/area").each do |area|
      region = Region.new
      region.name = area.xpath("@alt")[0].to_s
      region.aemet_key = area.xpath("@href")[0].to_s.sub("ultimosdatos?k=", "")

      puts "#{region.name} #{region.aemet_key}"

      region.save

      area.xpath
    end
  end

  task :load_cities do

    doc = Nokogiri::HTML(open("http://www.aemet.es/es/eltiempo/prediccion/localidades"))

    doc.xpath("//map[@id='map']/area").each do |area|

      doc_city = Nokogiri::HTML(open("http://www.aemet.es/"+(area.xpath("@href")[0])))
      
      doc_city.xpath("//table[@class='tabla_datos']//tr[@class='localidades']//a[strong]").each do |a|
        city = City.new

        i = Iconv.new('UTF-8','LATIN1')
        city.name = i.iconv(a.xpath("strong")[0].inner_html)
        
        city.aemet_key = a.xpath("@href")[0].to_s.sub("/es/eltiempo/prediccion/localidades/", "")

        puts "#{city.name} #{city.aemet_key}"

        city.save
      end

      area.xpath
    end
  end

  task :link_cities_regions do
   
       Region.all.each do |region|
         #we download the HTML of the summary
         doc_region = Nokogiri::HTML(open("http://www.aemet.es/es/eltiempo/observacion/ultimosdatos?k=#{region.aemet_key}&datos=det"))

         City.all.each do |city|
           unless doc_region.xpath("//table[@class='tabla_datos']/tbody/tr[th = '#{city.name}']/td").blank?
             region.cities << city
             city.region = region
             region.save
             city.save
             puts "#{region.name} --> #{city.name}"
           end
         end

       end
  end
end