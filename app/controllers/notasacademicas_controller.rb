class NotasacademicasController < ApplicationController
   before_filter :require_login, :only => [:new, :edit, :destroy, :show, :index]
   before_filter :authenticated_alum
  
  def index
    @periodo_actual = Periodo.last()    
    @asignaturas = Asignatura.joins(:distributivos => [:curso => :matriculas]).where(:matriculas => {:persona_id => current_user.persona.id})
    @cursos = Curso.joins(:matriculas).where(:matriculas => {:persona_id => current_user.persona.id}).last()
    @matriculas = Matricula.joins(:curso => :periodo).where(:persona_id => current_user.persona.id, :matr_estado=>["V","I"], :periodos => {:id => @periodo_actual.id})
  end
  
  def estadistica
    @asignaturas = Asignatura.joins(:distributivos => [:curso => :matriculas]).where(:matriculas => {:persona_id => current_user.persona.id})
    @cursos = Curso.joins(:matriculas).where(:matriculas => {:persona_id => current_user.persona.id})    
    @matriculas = Matricula.where(:persona_id => current_user.persona.id, :matr_estado=>["V","I"])
  end
end