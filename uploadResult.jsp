<%@page import="java.net.URLEncoder"%>
<%@page import="java.util.UUID"%>
<%@page import="java.io.File"%>
<%@page import="java.util.Iterator"%>
<%@page import="org.apache.commons.fileupload.FileItem"%>
<%@page import="java.util.List"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItem"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	//apache commons-fileupload를 이용한 request 처리
	
	//사용자의 요청이 익스플로러 계열인지 확인하기
	String agent=request.getHeader("User-Agent");
	boolean ieBrowser=(agent.indexOf("MSIE")>-1) || 
			(agent.indexOf("Trident")>-1) || (agent.indexOf("Edge")>-1);	
	
	//request안에 multipart/form-data가 있는지 확인
	boolean isMultipart=ServletFileUpload.isMultipartContent(request);

	if(isMultipart){
		//factory생성
		DiskFileItemFactory factory=new DiskFileItemFactory();
		ServletFileUpload upload=new ServletFileUpload(factory);
		
		//업로드 가능한 사이즈 지정
		upload.setSizeMax(2000*1024);
		
		//사용자의 요청 중 일반요소(Form field)와 file로 온 것 분리
		List<FileItem> items=upload.parseRequest(request);
		
		//해석된 구문 처리하기
		Iterator<FileItem> iter=items.iterator();
		while(iter.hasNext()){
			FileItem item=iter.next();
			
			if(item.isFormField()){//일반요소
				String fieldName=item.getFieldName();
				String value=item.getString("utf-8");
				out.print("<h3>일반 요소 출력</h3>");
				out.print(fieldName+" : "+value+"<br>");
			}else{//file요소
				
				
				String fieldName=item.getFieldName();
				//익스계열인 경우 fileName이 파일이 있었던 경로까지 포함해서 설정됨
				//fileName저장시 경로를 떼어내고 저장하기
				String fileName=null;
				if(ieBrowser){
					int pos=item.getName().lastIndexOf("\\");
					fileName=item.getName().substring(pos+1);
				}else{
					fileName=item.getName();
				}
				long sizeInBytes=item.getSize();			
		    					
				//파일저장				
				UUID id=UUID.randomUUID();
				File uploadfile=new File("c:/upload/"+id+"_"+fileName);
				
				//IE 11인 경우에 한글 파일명이 제대로 동작을 안함
				String encodeName=uploadfile.getName();
		    	//11인 경우에는 인코딩을 한 후 보낸다.
		    	if(agent.indexOf("Trident")>-1)
		    		encodeName=URLEncoder.encode(uploadfile.getName(),"utf-8");
								
				out.print("<h3>파일 요소 출력</h3>");
				out.print(fieldName+" : <a href='filedown.jsp?fileName="
							+encodeName+"'>"+fileName+"</a><br>");
				out.print("파일 크기 : "+sizeInBytes);	
				
				
				item.write(uploadfile);
			}
		}		
	}
%>