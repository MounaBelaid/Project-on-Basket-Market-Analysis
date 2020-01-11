library(shiny)
library(shinydashboard)
library(arules)
library(ggplot2)
library(DT)
library(Matrix)


shinyServer(function(input,output,session) {
  dsnames<-c()
  names<-c()
  

  
  data<-reactive({
    inFile<- input$file
    if(is.null(input$file))     return(NULL) 
    dataa<-read.csv(inFile$datapath,header=TRUE,sep=";")
    return(dataa)
  })
  
  output$tab<-DT::renderDataTable(
    DT::datatable(data(),class='compact',options=list( initComplete = JS(
      "function(settings, json) {",
      "$(this.api().table().header()).css({'background-color': '#3182bd', 'color': '#fff'});",
      "}")     
  )))
  
  dataset<-reactive({
    if(is.null(input$file))     return(NULL) 
    inFile<-input$file
    
    tr<-read.transactions(inFile$datapath,format="single",sep=",",cols=c(3,4),rm.duplicates = TRUE)
    
    rules<-apriori(tr,parameter=list(supp=input$slider1,conf=input$slider2))
    quality(rules)<-round(quality(rules),digits=3)
    rules.sorted<-sort(rules, by="lift")
    #subset.matrix<-is.subset(rules.sorted,rules.sorted)
    #subset.matrix[lower.tri(subset.matrix,diag=T)]<-NA
    #not.needed.rules<-colSums(subset.matrix,na.rm=T)>=1
    #new.rules<-rules.sorted[!not.needed.rules]
    dataTry<-as(rules.sorted,"data.frame")
    dataTry<-head(dataTry,20)
    dataTry<-dataTry[,-5]
    support_vect<-dataTry[,2]
    confidence_vect<-dataTry[,3]
    lift_vect<-dataTry[,4]
    dataTryCopy<-data.frame(dataTry$rules,support_vect,lift_vect,confidence_vect)
    colnames(dataTryCopy)<-c("rules","support","confidence","lift")
    data<-data.frame(dataTry$rules,lift_vect,dataTry$confidence,support_vect)
    colnames(data)<-c("rules","support","confidence","lift")
    newdata<-rbind(dataTry,dataTryCopy,data) #Creating a new dataset
    colnames(newdata)<-c("Rules","Support","Confidence","Values") 
    vect<-rep("Support",nrow(newdata)/3)
    vect1<-rep("Confiance",nrow(newdata)/3)
    vect2<-rep("Lift",nrow(newdata)/3)
    newvect<-c(vect2,vect1,vect)
    newdata<-data.frame(Règles=newdata$Rules,Valeurs=newdata$Values,Mesure=newvect) #Creating a new dataset
    return(newdata)
    })
  
   output$table<-DT::renderDataTable(
      DT::datatable(dataset(),class='compact',options=list( initComplete = JS(
        "function(settings, json) {",
        "$(this.api().table().header()).css({'background-color': '#3182bd', 'color': '#fff'});",
        "}")     
      )))
    
    bar<-reactive({
        ggplot(dataset(),aes(x=Règles,y=Valeurs,fill=Mesure,label=Valeurs))+
        xlab("Règles d'association")+
        ylab("Valeurs des mesures")+
        geom_bar(stat="identity",width=1,position=position_dodge())+geom_text(vjust=0.09, hjust=0.005,color="black",
    lineheight=3,position=position_dodge(0.9),size=3.5)+
        scale_fill_manual(values=c("#e41a1c","#377eb8","#4daf4a"))+
        theme_minimal()+theme(axis.text.x = element_text(angle=90,size=10,face="bold"),
                              axis.text.y=element_text(size=12,face="bold"),
                              axis.title.x = element_text(size=14, face="bold"),
                              axis.title.y = element_text(size=14, face="bold"),
                              legend.text=element_text(size=12,face="bold"),
                              legend.title=element_text(size=14,face="bold"),
                              legend.background = element_rect(fill="white",size=1, linetype="solid"))+
       coord_flip() })
    
    output$barplot<-renderPlot(bar())
    
    output$download<-downloadHandler(
      filename=function(){
        paste("barplot.jpg")
      },
      content=function(file){
        jpeg(file,width=1500,height=600)  
        plot(bar())
        dev.off()
      })
    
  
    
    Ville<-reactive({
      BD<-as.data.frame(table(data()[,1]))
      names(BD)<-c("Ville","Fréquence")
      BD<-BD[order(BD[,2],decreasing = TRUE),]
      return(BD) })
    
    output$newtable<-DT::renderDataTable(
      DT::datatable(Ville(),class='compact',options=list( initComplete = JS(
        "function(settings, json) {",
        "$(this.api().table().header()).css({'background-color': '#3182bd', 'color': '#fff'});",
        "}")     
      )))
    

    
    Client<-reactive({
      BDD<-as.data.frame(table(data()[,2]))
      names(BDD)<-c("Catégorie du client","Fréquence")
      BDD<-BDD[order(BDD[,2],decreasing = TRUE),]
      return(BDD)
    })
    
    output$newtab<-DT::renderDataTable(
      DT::datatable(Client(),class='compact',options=list( initComplete = JS(
        "function(settings, json) {",
        "$(this.api().table().header()).css({'background-color': '#3182bd', 'color': '#fff'});",
        "}")     
      ))
    )
})