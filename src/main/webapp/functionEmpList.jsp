<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
	/*
		단일값 함수를 이용한 쿼리
		select 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도
		from
		(select 
		    rownum 번호,
		    last_name 이름, substr(last_name, 1, 3) 이름첫글자, 
		    salary 연봉, round(salary/12, 2) 급여,
		    hire_date 입사날짜, extract(year from hire_date) 입사년도
		from employees)
		where 번호 between ? and ?;
		// 번호를 붙이기 위해 from절에 인라인 서브쿼리를 작성한다
	*/
	int currentPage = 1;
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	System.out.println(currentPage + " <--functionEmpList currentPage");
	
	//OracleDB에 접속
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dbUrl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbUser = "hr";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println(conn + " <--functionEmpList conn : 접속성공");
	
	// 페이지 구현을 위한 변수와 쿼리
	int totalRow = 0;
	String totalRowSql = "select count(*) from employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if(totalRowRs.next()){
		totalRow = totalRowRs.getInt(1); // totalRowRs.getInt("count(*)")
	}
	System.out.println(totalRow + " <--functionEmpList totalRow");
	
	int rowPerPage = 10;
	int beginRow = (currentPage-1)*rowPerPage + 1;
	int endRow = beginRow + rowPerPage - 1;
	if(endRow > totalRow){
		endRow = totalRow;
	}
	System.out.println(beginRow + " <--functionEmpList beginRow");
	System.out.println(endRow + " <--functionEmpList endRow");
	
	// 단일값 함수를 이용한 쿼리 출력
	String sql = "select 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도 from "
				+ "(select rownum 번호, last_name 이름, substr(last_name, 1, 1) 이름첫글자, salary 연봉, round(salary/12, 2) 급여, "
				+ "hire_date 입사날짜, extract(year from hire_date) 입사년도 from employees) "
				+ "where 번호 between ? and ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, beginRow);
	stmt.setInt(2, endRow);
	ResultSet rs = stmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
	while(rs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("번호", rs.getInt("번호"));
		m.put("이름", rs.getString("이름"));
		m.put("이름첫글자", rs.getString("이름첫글자"));
		m.put("연봉", rs.getInt("연봉"));
		m.put("급여", rs.getDouble("급여"));
		m.put("입사날짜", rs.getString("입사날짜"));
		m.put("입사년도", rs.getInt("입사년도"));
		list.add(m);
	}
	System.out.println(list.size() + " <--functionEmpList list.size()");
	
	// 페이지 네비게이션 -> 10대, 20대..를 구하는 패턴과 동일
	int pagePerPage = 10;
	/*
	currentPage	minPage	~	maxPage
		1		1		~	10
		2		1		~	10
		10		1		~	10
		
		11		11		~	10
		20		11		~	20
		minPage = ((currentPage-1)/pagePerPage)*pagePerPage + 1
		maxPage = minPage + (pagePerPage-1)
		maxPage < lastPage -- > maxPage = lastPage
	*/
	int lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0){
		lastPage = lastPage + 1;
	}
	int minPage = ((currentPage-1)/pagePerPage)*pagePerPage + 1;
	int maxPage = minPage + (pagePerPage-1);
	if(maxPage > lastPage){
		maxPage = lastPage;
	}
	System.out.println(lastPage + " <--functionEmpList lastPage");
	System.out.println(minPage + " <--functionEmpList minPage");
	System.out.println(maxPage + " <--functionEmpList maxPage");
	
	
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Function Employee List</title>
	<style>
		table, th, td {
			border: 1px solid #000000;
			border-collapse: collapse;
		}
	</style>
</head>
<body>
	<table>
		<tr>
			<th>번호</th>
			<th>이름</th>
			<th>이름첫글자</th>
			<th>연봉</th>
			<th>급여</th>
			<th>입사날짜</th>
			<th>입사년도</th>
		</tr>
		<%
			for(HashMap<String, Object> m : list){
		%>
				<tr>
					<td><%=(Integer)m.get("번호")%></td>
					<td><%=(String)m.get("이름")%></td>
					<td><%=(String)m.get("이름첫글자")%></td>
					<td><%=(Integer)m.get("연봉")%></td>
					<td><%=(Double)m.get("급여")%></td>
					<td><%=(String)m.get("입사날짜")%></td>
					<td><%=(Integer)m.get("입사년도")%></td>
				</tr>
		<%
			}
		%>
	</table>
	
	<!-- 페이지네이션 -->
	<%
		if(minPage>1){ // minPage가 1보다 큰 경우에만 '이전'항목이 나온다
	%>
			<a href="<%=request.getContextPath()%>/functionEmpList.jsp?currentPage=<%=minPage-1%>">이전</a>&nbsp;<!-- minPage-rowPerPage -->
	<%
		}
		for(int i=minPage; i<=maxPage; i=i+1){
			if(i == currentPage){
	%>
				<span><%=i%>&nbsp;</span>
	<%
			}else{
	%>
				<a href="<%=request.getContextPath()%>/functionEmpList.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;	
	<%
			}
		}
		if(maxPage != lastPage){
	%>
			<a href="<%=request.getContextPath()%>/functionEmpList.jsp?currentPage=<%=maxPage+1%>">다음</a>&nbsp;<!-- minPage + rowPerPage -->
	<%
		}	
	%>
</body>
</html>