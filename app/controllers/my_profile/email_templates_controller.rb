class EmailTemplatesController < MyProfileController

  protect 'manage_email_templates', :profile

  def index
    @email_templates = profile.email_templates
  end

  def show
    @email_template = profile.email_templates.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @email_template }
    end
  end

  def show_parsed
    @email_template = profile.email_templates.find(params[:id])
    template_params = {:profile => profile, :environment => environment}
    render json: {:parsed_body => @email_template.parsed_body(template_params), :parsed_subject => @email_template.parsed_subject(template_params)}
  end

  def new
    @email_template = profile.email_templates.build
  end

  def edit
    @email_template = profile.email_templates.find(params[:id])
  end

  def create
    @email_template = profile.email_templates.build(params[:email_template], :owner => profile)

    if @email_template.save
      session[:notice] = _('Email template was successfully created.')
      redirect_to url_for(:action => :index)
    else
      render action: "new"
    end
  end

  def update
    @email_template = profile.email_templates.find(params[:id])

    if @email_template.update_attributes(params[:email_template])
      session[:notice] = _('Email template was successfully updated.')
      redirect_to url_for(:action => :index)
    else
      render action: "edit"
    end
  end

  def destroy
    @email_template = profile.email_templates.find(params[:id])
    @email_template.destroy

    respond_to do |format|
      format.html { redirect_to url_for(:action => :index)}
      format.json { head :no_content }
    end
  end
end