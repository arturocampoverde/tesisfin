class SecretariasisController < ApplicationController
 before_filter :require_login, :only => [:new, :edit, :destroy, :show, :index]
 before_filter :authenticated_secreta
 
  
 
  
   helper_method :sort_column, :sort_direction
 
   def index 
    @estudio = Estudio.where(:persona_id => current_user.persona.id)
    @laboral = Laboral.where(:persona_id => current_user.persona.id)    
   end
   
  def new
    @estudio= Estudio.new
    @laboral= Laboral.new
  end

  
  
  
  
  
  
  
  
# BUSCAR DISTRIBUTIVO POR PERIODO LECTIVO  
  def ind_distr
    @periodos = Periodo.find(:all)
  end

  def result_busqueda
    @periodos = Periodo.where('period_fech_ini LIKE ?', params[:fecha_inicio]) unless params[:fecha_inicio].blank?
    @periodos = @periodos.where('period_fech_fin LIKE ?', params[:fecha_fin]) unless params[:fecha_fin].blank?
  end
  
  
  
  
  
# BUSCAR MALLAS CURRICULARES POR PERIODO LECTIVO
  def ind_mall
  @periodos_count = Periodo.count()
   if @periodos_count > 1
     @ultimo_periodo = Periodo.order("period_fech_ini").find(:last)
   else
     @ultimo_periodo = Periodo.find(:first)
   end
   
   @mallas = Malla.where(:mall_fech_fin => @ultimo_periodo.period_fech_fin)
  end
  
  def result_busquedamalla  
    @mallas = Malla.where('mall_fech_inic LIKE ?', params[:fecha_inicio]) unless params[:fecha_inicio].blank?
    @mallas = @mallas.where('mall_fech_fin LIKE ?', params[:fecha_fin]) unless params[:fecha_fin].blank?   
  end


  def buscar
    if params[:cedula_estudiante]==nil
      @estudiante = nil
      @usuario = nil
      @matricula = nil
      @representante = nil
    else
      @estudiante = Persona.find_by_pers_cedula(params[:cedula_estudiante])
      @usuario = User.find_by_persona_id(@estudiante.id)
      @matricula = Matricula.where(:persona_id=>@estudiante.id).last
      @representante = Persona.joins(:representantes).where(:representantes=>{:estudiante_id =>@estudiante.id}).first
    end
  end

  def activar
    usuario = User.joins(:persona).where(:personas=>{:id=>params[:estudiante]}).first
    User.find(usuario.id).update_attributes(usu_estado: "A")
    redirect_to secretariasis_menu_principal_secretaria_path
  end

  def validar
    matricula = Matricula.where(:persona_id => params[:estudiante]).last
    Matricula.find(matricula).update_attributes(matr_estado: "V")
    redirect_to secretariasis_menu_principal_secretaria_path
  end

  def historial
    # params[:estudiante] ES EL ID DE LA PERSONA
    @persona = Persona.find(params[:estudiante])
    @matriculas = Matricula.where(:persona_id => params[:estudiante])
    @periodos = Periodo.order("period_fech_ini").find(:all)
    @niveles = []
    @cursos = []
#    end
  end

  def homologacion_notas
    @persona = Persona.find(params[:persona_id])
    asignaturas_count = params[:contador_asig]
    asignaturas_count = asignaturas_count.to_i   
    matricula = Matricula.create(matr_fech: params[:periodo_fecha], matr_estado: "I", curso_id: params[:curso_id], persona_id: params[:persona_id])
    for i in 0..(asignaturas_count-1)
      Calificacione.create(calif_tarea: params[:tarea].at(i), calif_act_indv: params[:act_indiv].at(i), calif_act_grup: params[:act_grup].at(i), calif_leccion: params[:leccion].at(i), calif_examen: params[:examen].at(i), calif_total: params[:total].at(i), calif_promedio: params[:promedio].at(i), calif_cualit: params[:cualitativo].at(i), calif_conducta: params[:conducta].at(i), calif_estado: "APROBADO", asignatura_id: params[:asignatura_ids].at(i), matricula_id: matricula.id)
    end
    redirect_to historial_path(:estudiante=>@persona.id)
  end

  def matricula_secre
    periodo_last = Periodo.order("period_fech_ini").last
    @cursos_last = Curso.where(:periodo_id=>periodo_last.id)
    @persona = Persona.find(params[:persona_id])
  end

  def matr_alum
    curso = Curso.find(params[:curso_id])
    persona = Persona.find(params[:persona_id])
    periodo_last = Periodo.order("period_fech_ini").last
    Matricula.create(matr_fech: periodo_last.period_fech_ini, matr_estado: "V", curso_id: curso.id, persona_id: persona.id)
    User.find_by_persona_id(persona.id).update_attributes(usu_estado: "A")
    redirect_to result_buscar_path(:cedula_estudiante=>persona.pers_cedula)
  end

  def edit_historial
    matricula = Matricula.find(params[:matricula_id])
    @calificaciones = Calificacione.where(:matricula_id => matricula.id)
    @persona = Persona.find(params[:persona_id])
    #@asignaturas = Asignatura.joins(:calificaciones).where(:calificaciones=>{:matricula_id=>matricula.id})
  end

  def update_niveles
    #redirect_to secretariasis_menu_principal_secretaria_path
    nivel = Nivel.joins(:cursos=>:periodo).where(:periodos=>{:id => params[:periodo_id]}).uniq
    @niveles = nivel.map{|c| [c.nivel_numero, c.id]}.insert(0, "Seleccione un Nivel")
  end

  def update_cursos
    curso = Curso.joins(:nivel).where(:nivel_id=>params[:nivel_id], :periodo_id => params[:periodo_id])
    @periodo = Periodo.find(params[:periodo_id])
    @cursos = curso.map{|c| [c.cur_paralelo, c.id]}.insert(0, "Seleccione un Paralelo")
    
  end

  def update_homo
    @asignaturas = Asignatura.joins(:nivels).where(:nivels=>{:id=>params[:nivel_id]}).uniq
    @periodo = Periodo.find(params[:periodo_id])
    @asig_count = 0
    @asignaturas.each do
      @asig_count+=1
    end
    @persona = Persona.find(params[:persona_id])
    @curso = Curso.find(params[:curso_id])
  end

  def edit_matr_alum
    periodo_last = Periodo.order("period_fech_ini").last
    @cursos_last = Curso.where(:periodo_id=>periodo_last.id)
    @persona = Persona.find(params[:estudiante])
  end

  def update_notas_alum
    i = 0
    @persona = Persona.find(params[:persona_id])
    params[:asignatura_ids].each do |ci|
      @calif = Calificacione.find(ci)
      @calif.update_attributes(calif_tarea: params[:tarea].at(i), calif_act_indv: params[:act_indiv].at(i), calif_act_grup: params[:act_grup].at(i), calif_leccion: params[:leccion].at(i), calif_examen: params[:examen].at(i), calif_total: params[:total].at(i), calif_promedio: params[:promedio].at(i), calif_conducta: params[:conducta].at(i))
      i+=1
    end
    redirect_to historial_path(:estudiante=>@persona.id)
  end

  def update_matr_alum
    matricula = Matricula.where(:persona_id => params[:estudiante_id]).last
    Matricula.find(matricula).update_attributes(curso_id: params[:curso_id])
    persona = Persona.find(params[:estudiante_id])
    redirect_to result_buscar_path(:cedula_estudiante=>persona.pers_cedula)
  end

  
  
#BUSCAR ALUMNO POR MEDIO DE LA CEDULA Y VER SUS NOTAS 
#FALTAAAAAAAAAAAAAAAAA
#  def result_busquedapers
#    @personas = Persona.where('pers_cedula LIKE ?', params[:persona_cedula]) unless params[:persona_cedula].blank?
#    @mallas = @mallas.where('mall_fech_fin LIKE ?', params[:fecha_fin]) unless params[:fecha_fin].blank?
#  end
#  
#  def ind_perso
#    @personas = Persona.find(:all)
#  end

  
  
  
  
  
  

#BUSCAR LISTA DE ALUMNOS EN TODOS LOS CURSOS POR MEDIO DEL PERIODO LECTIVO
  def ind_estud
    #@periodos = Periodo.find(:all)
  end

  def result_estud
    @periodos = Periodo.where('period_fech_ini LIKE ?', params[:fecha_inicio]) unless params[:fecha_inicio].blank?
    @periodos = @periodos.where('period_fech_fin LIKE ?', params[:fecha_fin]) unless params[:fecha_fin].blank?
  end

  
  
  
  def estudiantes_curso
    curso_id = params[:curso_id]
    @estudiantes = Persona.joins(:matriculas).where(:matriculas => {:curso_id => curso_id})
  end
  
  
  
  
  
  def ind_estud_estado
    #@periodos = Periodo.find(:all)
  end


  def result_estud_estado
    @periodos = Periodo.where('period_fech_ini LIKE ?', params[:fecha_inicio]) unless params[:fecha_inicio].blank?
    @periodos = @periodos.where('period_fech_fin LIKE ?', params[:fecha_fin]) unless params[:fecha_fin].blank?
  end

  def estudiantes_estado
    curso_id = params[:curso_id]
    #@estudiantes = Persona.joins(:matriculas).where(:matriculas => {:curso_id => curso_id})
    @matriculas = Matricula.where(:curso_id => curso_id)
    
    
  end
  
  
  
  def create
    @estudio = Estudio.new(params[:estudio])
    @laboral = Laboral.new(params[:laboral])              
     
    @laboral.persona_id = current_user.persona.id
    @estudio.persona_id = current_user.persona.id
            
    if @estudio.save and @laboral.save
      redirect_to secretariasis_menu_principal_secretaria_path,  :notice => 'CURRICULUM CREADO'
    else
    render :new
    end
  end
  
     
            
   def edit 
     @estudios = Estudio.find(params[:id])
     @laborals = Laboral.find(params[:id])     
     if @estudios.persona.id and @laborals.persona.id == current_user.persona_id
     
     else
     
      :render_404  
     
       
       if @estudios.id.present? and @laborals.id.present?
       
       flash[:error] = ""
       redirect_to secretariasis_menu_principal_secretaria_path
     end         
   end
   end
   
#render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false MUESTRA MENSAJE DE ERROR DE URL INCORRECTA      
#    modelo = Modelo.find(params[:id]) rescue nil
#    redirect_to root_path if modelo.nil?
   
    
   
   
   def update
     @estudio= Estudio.find (params[:id])
     @estudio.update_attributes(params[:estudio])
     @laboral= Laboral.find (params[:id])
     @laboral.update_attributes(params[:laboral])
     redirect_to secretariasis_menu_principal_secretaria_path ,  :notice => 'CURRICULUM ACTUALIZADO'   
   end
   
   
     private
  def sort_column
    @periodos = Periodo.where('period_fech_ini LIKE ?', params[:fecha_inicio]) unless params[:fecha_inicio].blank?
    @periodos = @periodos.where('period_fech_fin LIKE ?', params[:fecha_fin]) unless params[:fecha_fin].blank?
    @periodos = Nivel.joins(:cursos => :periodo).where(:periodos => {:id => @periodos})
    Nivel.column_names.include?(params[:sort]) ? params[:sort] : "nivel_numero"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
  end
   
end