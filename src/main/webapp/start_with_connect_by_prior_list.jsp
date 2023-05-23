<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
	//DB접속
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dbUrl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbUser = "hr";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println(conn);
	
	//계층쿼리(start with ... connect by prior ...) : 데이터의 계층을 알 수 있다
	//employees테이블에서 manager_id와 같은 이름의 employee_id로 연결하여 계층을 보여준다
	//LEVEL: 트리의 level을 출력
	//SYS_CONNECT_BY_PATH(컬럼명, char): 해당 컬럼명을 구분자를 이용하여 계층출력
	//LPAD(값, 문자길이, 채움문자): 해당'값'을 '문자길이'가 되도록 출력하고 모자란 부분은 '채움문자'로 채운다 
	String treeSql = "SELECT level 레벨, LPAD(' ', level, '_')||first_name 이름, manager_id 관리자번호, department_id 부서번호, SYS_CONNECT_BY_PATH(first_name, '-') 계층 "
						+"FROM employees "
						+"START WITH manager_id IS NULL CONNECT BY PRIOR employee_id = manager_id";
	PreparedStatement treeStmt = conn.prepareStatement(treeSql);
	ResultSet treeRs = treeStmt.executeQuery();
	
	//ResultStet -> ArrayList<HashMap<String, Object>>
	ArrayList<HashMap<String, Object>> treeList = new ArrayList<HashMap<String, Object>>();
	while(treeRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("레벨", treeRs.getInt("레벨"));
		m.put("이름", treeRs.getString("이름"));
		m.put("관리자번호", treeRs.getInt("관리자번호"));
		m.put("부서번호", treeRs.getInt("부서번호"));
		m.put("계층", treeRs.getString("계층"));
		treeList.add(m);
	}
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>start with connect by prior list</title>
	<!-- 부트스트랩5 -->
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
	<div class="container">
	<h1>계층쿼리</h1>
	<p>SQL: SELECT level 레벨, LPAD(' ', level-1)||first_name 이름, manager_id 관리자번호, department_id 부서번호, SYS_CONNECT_BY_PATH(first_name, '-') 계층 <br>
		FROM employees <br>
		START WITH manager_id IS NULL CONNECT BY PRIOR employee_id = manager_id;</p>
	<table class="table table-bordered">
		<tr>
			<th>레벨</th>
			<th>이름</th>
			<th>관리자번호</th>
			<th>부서번호</th>
			<th>계층</th>
		</tr>
		<%
			for(HashMap<String, Object> m : treeList){
		%>
				<tr>
					<td><%=(Integer)m.get("레벨")%></td>
					<td><%=(String)m.get("이름")%></td>
					<td><%=(Integer)m.get("관리자번호")%></td>
					<td><%=(Integer)m.get("부서번호")%></td>
					<td><%=(String)m.get("계층")%></td>
				</tr>
		<%
			}
		%>
	</table>
	</div>
</body>
</html>