<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
	//1. 컨트롤러 계층
	//요청값 넘어오는지 확인
	System.out.println(request.getParameter("currentPage") + " <--windeowsFunctionEmpList param currentPage");

	int currentPage = 1;
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	int rowPerPage = 10;
	int startRow = (currentPage-1)*rowPerPage + 1;
	int endRow = startRow + rowPerPage - 1;
			
	//2. 모델계층
	/*
		select rnum, 사원ID, 성, 급여, 전체급여평균, 전체급여합계, 전체사원수
		from
			(select rownum rnum, employee_id, last_name, salary, 
			    round(avg(salary) over()) 전체급여평균,
			    sum(salary) over() 전체급여합계,
			    count(*) over() 전체사원수 from employees)
		where rnum between 1 and 10;
	*/
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dbUrl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbUser = "hr";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println(conn + " <--windowsFunctionEmpList conn : 접속성공");
	
	//페이징을 위한 변수와 쿼리
	int totalRow = 0;
	
	// 마지막 페이지를 구하기 위한 총 행의 수 구하기
	String totalRowSql = "select count(*) cnt from employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if(totalRowRs.next()){
		totalRow = totalRowRs.getInt("cnt");
	}
	System.out.println(totalRow+ " <--windowsFunctionEmpList totalRow");
	int lastPage = totalRow / rowPerPage;
	// 총 행의 수를 rowPerPage로 나누어떨어지지 않을 때는 lastPage + 1
	if(totalRow % rowPerPage != 0){
		lastPage = lastPage + 1;
	}
	System.out.println(lastPage + "<--windowsFunctionEmpList lastPage");
	
	// currentPage를 이용하여 출력되는 최소페이지와 최대페이지를 구한다
	int pagePerPage = 10;
	int minPage = ((currentPage-1)/pagePerPage)*pagePerPage + 1;
	int maxPage = minPage + pagePerPage - 1;
	// 페이지블럭의 최대페이지가 마지막 페이지보다 크면 마지막 페이지가 그 블럭의 최대페이지가 된다
	if(maxPage > lastPage){
		maxPage = lastPage;
	}
	System.out.println(minPage + "<--windowsFunctionEmpList minPage");
	System.out.println(maxPage + "<--windowsFunctionEmpList maxPage");
	
	//사원목록 출력을 위한 쿼리
	String winFuncSql = "";
	PreparedStatement winFuncStmt = null;
	ResultSet winFuncRs = null;
	
	winFuncSql = "select rnum, 사원ID, 성, 급여, 전체급여평균, 전체급여합계, 전체사원수 "
				+ "from (select rownum rnum, employee_id 사원ID, last_name 성, salary 급여, round(avg(salary) over()) 전체급여평균, sum(salary) over() 전체급여합계,  count(*) over() 전체사원수 from employees) "
				+ "where rnum between ? and ?";
	winFuncStmt = conn.prepareStatement(winFuncSql);
	winFuncStmt.setInt(1, startRow);
	winFuncStmt.setInt(2, endRow);
	winFuncRs = winFuncStmt.executeQuery();
	
	// ResultSet -> ArrayList
	ArrayList<HashMap<String, Object>> empList = new ArrayList<HashMap<String, Object>>();
	while(winFuncRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("사원ID", winFuncRs.getInt("사원ID"));
		m.put("성", winFuncRs.getString("성"));
		m.put("급여", winFuncRs.getInt("급여"));
		m.put("전체급여평균", winFuncRs.getInt("전체급여평균"));
		m.put("전체급여합계", winFuncRs.getInt("전체급여합계"));
		m.put("전체사원수", winFuncRs.getInt("전체사원수"));
		empList.add(m);
	}
	System.out.println(empList.size() + " <--windowsFunctionEmpList empList.size()");

%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Window Function Employee List</title>
	<style>
		table, td, th {
			border: 1px solid #000000;
			border-collapse: collapse;
		}
	</style>
</head>
<body>
	<h1>분석함수를 이용한 사원목록 출력</h1>
	<P>
		select rnum, 사원ID, 성, 급여, 전체급여평균, 전체급여합계, 전체사원수<br>
		from<br>
			(select rownum rnum, employee_id, last_name, salary, <br>
			    round(avg(salary) over()) 전체급여평균,<br>
			    sum(salary) over() 전체급여합계,<br>
			    count(*) over() 전체사원수 from employees)<br>
		where rnum between 1 and 10;
	</P>
	<table>
		<tr>
			<th>사원ID</th>
			<th>성</th>
			<th>급여</th>
			<th>전체급여평균</th>
			<th>전체급여합계</th>
			<th>전체사원수</th>
		</tr>
		<%
			for(HashMap<String, Object> m : empList){
		%>
				<tr>
					<td><%=(Integer)m.get("사원ID")%></td> <!-- object타입은 형변환 해주기 -->
					<td><%=(String)m.get("성")%></td>
					<td><%=(Integer)m.get("급여")%></td>
					<td><%=(Integer)m.get("전체급여평균")%></td>
					<td><%=(Integer)m.get("전체급여합계")%></td>
					<td><%=(Integer)m.get("전체사원수")%></td>
				</tr>
		<%
			}
		%>
	</table>
	
	<!-- 페이지네이션 -->
	<%
		if(minPage > 1){ // 보이는 페이지 블럭에서 첫번쨰 페이지가 1인 경우에는 이전 버튼 출력하지 않음
	%>
			<a href="<%=request.getContextPath()%>/windowsFunctionEmpList.jsp?currentPage=<%=minPage-1%>">이전&nbsp;</a>
	<%		
		}
	%>
	
	<%
		for(int i=minPage; i<=maxPage; i+=1){ // 페이지블럭의 페이지 출력
			if(i == currentPage){ //현재페이지는 링크없이 페이지 번호만 출력
	%>
			<%=i%>&nbsp;
	<%
			} else {		
	%>
			<a href="<%=request.getContextPath()%>/windowsFunctionEmpList.jsp?currentPage=<%=i%>"><%=i%>&nbsp;</a>
	<%
			}
		}
	%>
	<%
		if(maxPage != lastPage){ // 마지막 페이지에서는 다음 버튼 출력하지 않음
	%>
			<a href="<%=request.getContextPath()%>/windowsFunctionEmpList.jsp?currentPage=<%=maxPage+1%>">다음&nbsp;</a>
	<%
		}
	%>
	
</body>
</html>