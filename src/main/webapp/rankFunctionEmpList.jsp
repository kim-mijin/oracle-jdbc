<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
	//1. 컨트롤러 계층
	//요청값 넘어오는지 확인
	System.out.println(request.getParameter("currentPage") + " <--rankFunctionEmpList param currentPage");
	
	int currentPage = 1;
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	int rowPerPage = 10;
	int startRow = (currentPage-1)*rowPerPage + 1;
	int endRow = startRow + rowPerPage - 1;
			
	//2. 모델계층
	/*
		select t.사원ID, t.성, t.급여, t.급여순위 from
		(select rownum rnum, e.사원ID, e.성, e.급여, e.급여순위 from
		(select employee_id 사원ID, last_name 성, salary 급여, rank() over(order by salary desc) 급여순위 from employees) e) t
		where rnum between ? and ?
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
	//마지막 페이지를 위한 총 행의 수 구하기
	int totalRow = 0;
	
	String totalRowSql = "select count(*) cnt from employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if(totalRowRs.next()){
		totalRow = totalRowRs.getInt("cnt");
	}
	System.out.println(totalRow+ " <--rankFunctionEmpList totalRow");
	
	// 마지막 페이지는 총 행의 수를 rowPerPage로 나눈 몫
	int lastPage = totalRow / rowPerPage;
	// 마지막페이지가 rowPerPage로 나누어 떨어지지 않는 경우에는 1을 더한다
	if(totalRow % rowPerPage != 0){
		lastPage = lastPage + 1;
	}
	System.out.println(lastPage + "<--rankFunctionEmpList lastPage");
	
	// currentPage를 이용하여 출력되는 최소페이지와 최대페이지를 구한다
	int pagePerPage = 10;
	int minPage = ((currentPage-1)/pagePerPage)*pagePerPage + 1;
	int maxPage = minPage + pagePerPage - 1;
	// 최대페이지가 마지막페이지보다 큰 경우에는 마지막페이지가 최대페이지가 된다	
	if(maxPage > lastPage){
		maxPage = lastPage;
	}
	System.out.println(minPage + "<--rankFunctionEmpList minPage");
	System.out.println(maxPage + "<--rankFunctionEmpList maxPage");
	
	
	// 데이터를 출력하기 위한 쿼리
	String rankFuncSql = "select t.사원ID, t.성, t.급여, t.급여순위 from "
						+ "(select rownum rnum, e.사원ID, e.성, e.급여, e.급여순위 from "
						+ "(select employee_id 사원ID, last_name 성, salary 급여, rank() over(order by salary desc) 급여순위 from employees) e) t "
						+ "where rnum between ? and ?";
	PreparedStatement rankFuncStmt = conn.prepareCall(rankFuncSql);
	rankFuncStmt.setInt(1, startRow);
	rankFuncStmt.setInt(2, endRow);
	ResultSet rankFuncRs = rankFuncStmt.executeQuery();
	
	// ResultSet -> ArrayList
	ArrayList<HashMap<String, Object>> empList = new ArrayList<HashMap<String, Object>>();
	while(rankFuncRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("사원ID", rankFuncRs.getInt("사원ID"));
		m.put("성", rankFuncRs.getString("성"));
		m.put("급여", rankFuncRs.getInt("급여"));
		m.put("급여순위", rankFuncRs.getInt("급여순위"));
		empList.add(m);
	}
	System.out.println(empList.size() + " <--rankFunctionEmpList empList.size()");
	
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
	<title>Rank Function Employee List</title>
	</head>
	<style>
		table, th, td {
			border: 1px solid #000000;
			border-collapse: collapse;
		}
	</style>
<body>
	<h1>rank()를 이용한 사원목록 출력</h1>
	<P>
		select t.사원ID, t.성, t.급여, t.급여순위 from<br>
		(select rownum rnum, e.사원ID, e.성, e.급여, e.급여순위 from<br>
		(select employee_id 사원ID, last_name 성, salary 급여, rank() over(order by salary desc) 급여순위 from employees) e) t<br>
		where rnum between ? and ?
	</P>
	<table>
		<tr>
			<th>사원ID</th>
			<th>성</th>
			<th>급여</th>
			<th>급여순위</th>
		</tr>
		<%
			for(HashMap<String, Object> m : empList){
		%>
				<tr>
					<td><%=(Integer)m.get("사원ID")%></td> <!-- object타입은 형변환 해주기 -->
					<td><%=(String)m.get("성")%></td>
					<td><%=(Integer)m.get("급여")%></td>
					<td><%=(Integer)m.get("급여순위")%></td>
				</tr>
		<%
			}
		%>
	</table>
	
	<!-- 페이지네이션 -->
	<%
		if(minPage > 1){ //페이지블럭의 최소페이지가 1이 아닌 경우에만 '이전' 버튼이 보인다
	%>
			<a href="<%=request.getContextPath()%>/rankFunctionEmpList.jsp?currentPage=<%=minPage-1%>">이전&nbsp;</a>
	<%		
		}
	%>
	
	<%
		for(int i=minPage; i<=maxPage; i+=1){ //현재 보이는 페이지블럭은 최소페이지 ~ 최대페이지
			if(i == currentPage){ // 현재페이지에서는 링크 없이 페이지 번호만 출력
	%>
				<%=i%>&nbsp;
	<%
			} else {
	%>
				<a href="<%=request.getContextPath()%>/rankFunctionEmpList.jsp?currentPage=<%=i%>"><%=i%>&nbsp;</a>
	<%
			}
		}
	%>
	<%
		if(maxPage != lastPage){ //마지막페이지에서는 '다음' 버튼이 보이지 않는다
	%>
			<a href="<%=request.getContextPath()%>/rankFunctionEmpList.jsp?currentPage=<%=maxPage+1%>">다음&nbsp;</a>
	<%
		}
	%>
</body>
</html>