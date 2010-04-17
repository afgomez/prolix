namespace :aemet do

  require 'nokogiri'
  require 'open-uri'
  require "mongo_mapper"
  require "#{RAILS_ROOT}/config/initializers/mongodb"
  require 'region'
  require 'city'
  require 'day'
  require 'prediction'
  require 'observation'
#    Dir[File.expand_path(File.join(File.dirname(__FILE__),"#{RAILS_ROOT}/app/models/",'**','*.rb'))].each {|f| require f}


  months = ["enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"]

  task :predictions do

    Region.all.each do |region|
      salida = ""
      doc_region = Nokogiri::HTML(open("http://www.aemet.es/es/eltiempo/observacion/ultimosdatos?k=#{region.aemet_key}&datos=det"))

      region.cities.each do |city|
       
        info = doc_region.xpath("//table[@class='tabla_datos']/tbody/tr[th = '#{city.name}']/td")

        puts " - #{city.name}"

        doc_city = Nokogiri::HTML(open("http://www.aemet.es/es/eltiempo/prediccion/localidades/#{city.aemet_key}"))

        7.times do |i|

          puts Date.today + i
          day = city.days.select { |d| d.date == (Date.today + i) }
          day = day[0]
          
          if day.nil?
            day = Day.new :date => (Date.today + i)
            city.days << day
            city.save
          end


          prediction = day.predictions.select { |p| p.date == (Date.today + i) }
          prediction = prediction[0]
          if prediction.nil?
            pop = 0
            temp_min = 0
            temp_max = 0
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

            prediction = Prediction.new
            prediction.date = (Date.today + i)
            prediction.pop = pop
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

    Region.all.each do |region|

      doc_region = Nokogiri::HTML(open("http://www.aemet.es/es/eltiempo/observacion/ultimosdatos?k=#{region.aemet_key}&datos=det"))

      region.cities.each do |city|

        day = city.days.select { |d| d.date == (Date.today -1) }
        day = day[0]

        if day.nil?
          day = Day.new :date => (Date.today - 1)
          city.days << day
          day.save
          city.save
        end

        info = doc_region.xpath("//table[@class='tabla_datos']/tbody/tr[th = '#{city.name}']/td")

        puts " - #{city.name}"

        salida =  "#{Date.today-1}\t#{info[2].content.to_f}\t#{info[0].content.to_f}\t#{info[1].content.to_f}\n"

        summary = day.observations.select { |o| o.hour.nil? }
        summary = summary[0]
        if summary.nil?
          summary = Observation.new(
               :max => info[0].content.to_f,
               :min => info[1].content.to_f,
               :pop => info[2].content.to_f)
          day.observations << summary
          summary.save
          day.save
        end


        day = city.days.select { |d| d.date == (Date.today) }
        day = day[0]
        if day.nil?
          day = Day.new :date => (Date.today)
          city.days << day
          city.save
        end

        4.times.each do |i|

          observation = day.observations.select { |o| o.hour == (i*6) + 2 }
          observation = observation[0]
          if observation.nil?

            doc = Nokogiri::HTML(open("http://www.aemet.es/es/eltiempo/observacion/ultimosdatos?k=#{region.aemet_key}&datos=det&w=H#{i+1}"))
            puts "#{Date.today.day} #{months[Date.today.month-1]} #{Date.today.year}"
            unless doc.xpath("//*[@class='notas_tabla']").inner_html.index("#{Date.today.day} #{months[Date.today.month-1]} #{Date.today.year}").nil?
              info = doc.xpath("//table[@class='tabla_datos']/tbody/tr[th = '#{city.name}']/td")
              salida +=  "#{Date.today} #{(i*6) + 2}:00\t#{info[3].content.to_f}\t#{info[5].content.to_f}\n"
            end

            observation = Observation.new( :hour => (i*6) + 2,
               :min => info[3].content.to_f,
               :max=> info[3].content.to_f,
               :pop => info[5].content.to_f)

            day.observations << observation
            observation.save
            day.save

          end

          puts salida
        end
      end
    end
  end
end