library(data.table)
library(magrittr)
library(ggplot2)
library(viridis)

server = function(input, output){
  # pixel height for each panel. i.e row height when plotting by species
  height_per_panel = 350

  # load data needed for shiny app
    summary_dt = fread(file="./shiny-data/summary.csv")

  ref_table_reduced = summary_dt %>%
                as.data.frame(.)

  output$summarytable = DT::renderDataTable({
    summary_df = summary_dt %>%
                 as.data.frame(.,stringsAsFactors=FALSE)
    summary_DT = DT::datatable(summary_df, filter = 'top',rownames=FALSE,
    options = list(scrollX = TRUE, search = list(regex = TRUE, caseInsensitive = FALSE),pageLength = 25))
    return(summary_DT)
  })
  outputOptions(output, "summarytable", suspendWhenHidden = FALSE)

  filtered_id = reactive({
    req(input$summarytable_rows_selected)
    keep_models = c(ref_table_reduced[input$summarytable_rows_selected, ]$model_name)
    return(keep_models)  
  })

  # define plots
  output$srr_plots = renderPlot({
    input_models = unique(filtered_id())
    if(length(input_models) < 1 ){
      return(warning("Please select at least one model."))
    }

    expected_srr_dt = fread(file="./shiny-data/expected_srr.csv") %>%
                      .[model_name %in% input_models]
    est_recruit_dt = fread(file="./shiny-data/est_recruit.csv") %>%
                      .[model_name %in% input_models]

    p = expected_srr_dt %>%
      ggplot() +
			ylim(0,NA) +
			xlab("Spawning biomass (SSB)") +
            ylab("Recruitment") +
            geom_path(aes(x=ssb,y=rec_actual,group=model_name,color=model_name),linewidth=1.5)

      if(input$srr_show_est == "TRUE")
      {
        if(input$srr_est_type == "Path"){
            p = p + geom_line(data=est_recruit_dt,aes(x=ssb,y=rec_estimated,group=model_name,color=model_name),alpha=0.5)
        } else if(input$srr_est_type == "Points"){
            p = p + geom_point(data=est_recruit_dt,aes(x=ssb,y=rec_estimated,group=model_name,fill=model_name),shape=21,cex=3)
        } else {
            p = p + geom_line(data=est_recruit_dt,aes(x=ssb,y=rec_estimated,group=model_name,color=model_name),alpha=0.5)
            p = p + geom_point(data=est_recruit_dt,aes(x=ssb,y=rec_estimated,group=model_name,fill=model_name),shape=21,cex=3)
        }
      }
	  
    
      p = p + viridis::scale_color_viridis("Model",begin = 0.1,end = 0.8,direction = 1,option = "H",discrete=TRUE) +
			viridis::scale_fill_viridis("Model",begin = 0.1,end = 0.8,direction = 1,option = "H",discrete=TRUE) +
			theme(panel.background = element_rect(fill = "white", color = "black", linetype = "solid"),
							panel.grid.major = element_line(color = 'gray70',linetype = "dotted"), 
							panel.grid.minor = element_line(color = 'gray70',linetype = "dotted"),
							strip.background =element_rect(fill="white"),
							legend.key = element_rect(fill = "white"))
			
    return(p)
  },
  height=function(){
    return((height_per_panel*1.5))
  })

  # add natural mortality plot
  output$natM_plots = renderPlot({

    if(length(input$natM_dropdown)>0){
      input_models = unique(input$natM_dropdown)
    } else {
      input_models = unique(filtered_id())
    }

    if(length(input_models) < 1 ){
      return(warning("Please select at least one model."))
    }

    m_at_age_dt = fread(file="./shiny-data/m_at_age.csv") %>%
                      .[model_name %in% input_models]
    
    p = m_at_age_dt %>%
      ggplot() +
			ylim(0,NA) +
			xlab("Age (years)") +
      ylab("Natural mortality (M)") +
      facet_wrap(~Sex,nrow=1)

        if(input$natM_plot_type == "Path"){
            p = p + geom_line(data=m_at_age_dt,aes(x=age,y=value,group=model_name,color=model_name),alpha=0.5)
        } else if(input$natM_plot_type == "Points"){
            p = p + geom_point(data=m_at_age_dt,aes(x=age,y=value,group=model_name,fill=model_name),shape=21,cex=3)
        } else {
            p = p + geom_line(data=m_at_age_dt,aes(x=age,y=value,group=model_name,color=model_name),alpha=0.5)
            p = p + geom_point(data=m_at_age_dt,aes(x=age,y=value,group=model_name,fill=model_name),shape=21,cex=3)
        }

      p = p + viridis::scale_color_viridis("Model",begin = 0.1,end = 0.8,direction = 1,option = "H",discrete=TRUE) +
			viridis::scale_fill_viridis("Model",begin = 0.1,end = 0.8,direction = 1,option = "H",discrete=TRUE) +
			theme(panel.background = element_rect(fill = "white", color = "black", linetype = "solid"),
							panel.grid.major = element_line(color = 'gray70',linetype = "dotted"), 
							panel.grid.minor = element_line(color = 'gray70',linetype = "dotted"),
							strip.background =element_rect(fill="white"),
							legend.key = element_rect(fill = "white"))
			
    return(p)

  },
  height=function(){
    return((height_per_panel*1.5))
  })

    
}
