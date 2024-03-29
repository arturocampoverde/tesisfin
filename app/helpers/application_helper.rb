module ApplicationHelper
    def sortable(column, title)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current &crarr;
    #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ?  "desc" : "asc"
    link_to title, params.merge(:sort => column, :direction => direction), {:class => css_class}
  end  
end