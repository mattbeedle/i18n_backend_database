require 'digest/md5'

class Translation
  include Mongoid::Document

  field :key
  field :raw_key
  field :value
  field :pluralization_index, :type => Integer

  belongs_to_related :locale
  validates_presence_of :key
  before_validate :generate_hash_key, :on => :create
  after_update  :update_cache

  named_scope :untranslated, :conditions => { :value => nil }, :order => 'raw_key'
  named_scope :translated,   :conditions => { :value => { "$ne" => nil } }, :order => 'raw_key'

  def default_locale_value(rescue_value='No default locale value')
    begin
      #Locale.default_locale.translations.find_by_key_and_pluralization_index(self.key, self.pluralization_index).value
      Locale.default_locale.translations.first(:conditions => { :key => self.key, :pluralization_index => self.pluralization_index }).value
    rescue
      rescue_value
    end
  end

  def value_or_default
    value = self.value || self.default_locale_value(self.raw_key)
    value =~ /^---(.*)\n/ ? YAML.load(value) : value  # supports using YAML e.g. order: [ :year, :month, :day ] values are stored as Symbols "--- :year\n", "--- :month\n", "--- :day\n"
  end

  # create hash key
  def self.hk(key)
    Base64.encode64(Digest::MD5.hexdigest(key.to_s)).gsub(/\n/, '')
  end

  # create cache key
  def self.ck(locale, key, hash=true)
    key = self.hk(key) if hash
    "#{locale.code}:#{key}"
  end

  protected
    def generate_hash_key
      self.raw_key = key.to_s
      self.key = Translation.hk(key)
    end

    def update_cache
      new_cache_key = Translation.ck(self.locale, self.key, false)
      I18n.backend.cache_store.write(new_cache_key, self.value)
    end
end
