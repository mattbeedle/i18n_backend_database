class TranslationsController < ActionController::Base
  unloadable

  prepend_view_path(File.join(File.dirname(__FILE__), "..", "views"))
  layout 'translations'
  before_filter :find_locale

  ## FIXME:  you'll probably want add authorization to this controller!

  def index
    @translations = @locale.translations.all(:order => "raw_key, pluralization_index")
  end

  def translations
    @locale ||= Locale.default_locale
    @translation_option = TranslationOption.find(params[:translation_option])

    if @translation_option == TranslationOption.translated
      @translations = @locale.translations.translated
    else
      @translations = @locale.translations.untranslated
    end
  end

  def asset_translations
    @locale ||= Locale.default_locale
    @translation_option = TranslationOption.find(params[:translation_option])

    @asset_translations  = I18n.asset_translations
    @untranslated_assets = I18n.untranslated_assets(@locale.code)
    @percentage_translated =   (((@asset_translations.size - @untranslated_assets.size).to_f / @asset_translations.size.to_f * 100).round) rescue 0

    if @translation_option == TranslationOption.translated
      @asset_translations = @asset_translations.reject{|e| @untranslated_assets.include?(e)}
    else
      @asset_translations = @untranslated_assets
    end
  end

  def show
    @translation = @locale.translations.find(params[:id])
  end

  def new
    @translation = Translation.new
  end

  def edit
    @translation = @locale.translations.find(params[:id])
  end

  def create
    @translation = @locale.translations.build(params[:translation])

    if @translation.save
      flash[:notice] = 'Translation was successfully created.'
      redirect_to locale_translation_path(@locale, @translation)
    else
      render :action => "new"
    end
  end

  def update
    @translation  = @locale.translations.find(params[:id])
    @first_time_translating = @translation.value.nil?

    if @translation.update_attributes(params[:translation])
      flash[:notice] = 'Translation was successfully updated.'
      redirect_to locale_translation_path(@locale, @translation)
    else
      render :action => "edit"
    end
  end

  # DELETE /translations/1
  # DELETE /translations/1.xml
  def destroy
    @translation = @locale.translations.find(params[:id])
    @translation.destroy
    redirect_to(locale_translations_url)
  end

  private

    def find_locale
      @locale = Locale.find_by_code(params[:locale_id])
    end
end
