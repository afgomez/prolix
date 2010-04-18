class City
  include MongoMapper::Document

  key :aemet_key, String
  key :name, String
  key :region, Mongo::ObjectID
  key :general_prediction_success, Float
  key :nicetitle

  many :days
  belongs_to :region

  before_save :make_nicetitle  

  class << self
    def best
      City.all(:order => 'general_prediction_success DESC', :limit => 5)
    end

    def worst
      City.all(:order => 'general_prediction_success ASC', :limit => 5)
    end
  end  

  def get_day_from_today(jump)
    self.days.all.select { |d| d.date == (Date.today + jump.days) }
  end

  def to_params
    self.nicetitle
  end

  private

  def make_nicetitle    
    if nicetitle.blank?
      if defined?(Unicode)
        str = Unicode.normalize_KD(self.name).gsub(/[^\x00-\x7F]/n,'')
        str = str.gsub(/\W+/, '-').gsub(/^-+/,'').gsub(/-+$/,'').downcase
        self.nicetitle = str
      else
        str = Iconv.iconv('ascii//translit', 'utf-8', self.name).to_s
        str.gsub!(/\W+/, ' ')
        str.strip!
        str.downcase!
        str.gsub!(/\ +/, '-')
        self.nicetitle = str
      end
    end
  end

end
