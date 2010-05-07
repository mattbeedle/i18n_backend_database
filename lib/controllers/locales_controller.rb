class LocalesController < ActionController::Base
  unloadable

  prepend_view_path(File.join(File.dirname(__FILE__), "..", "views"))

  def index
    @locales = Locale.all
  end

  def show
    @locale = Locale.find_by_code(params[:id])
  end

  def new
    @locale = Locale.new
  end

  def edit
    @locale = Locale.find_by_code(params[:id])
  end

  def create
    @locale = Locale.new(params[:locale])

    if @locale.save
      flash[:notice] = 'Locale was successfully created.'
      redirect_to(@locale)
    else
      render :action => "new"
    end
  end

  def update
    @locale = Locale.find_by_code(params[:id])

    if @locale.update_attributes(params[:locale])
      flash[:notice] = 'Locale was successfully updated.'
      redirect_to(@locale)
    else
      render :action => "edit"
    end
  end

  # DELETE /locales/1
  # DELETE /locales/1.xml
  def destroy
    @locale = Locale.find_by_code(params[:id])
    @locale.destroy

    redirect_to(locales_url)
  end
end
