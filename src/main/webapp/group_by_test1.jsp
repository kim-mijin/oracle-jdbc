<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
	/*
		select 
			department_id 부서ID, 
			count(*) 부서인원, 
			sum(salary) 급여합계, 
			round(avg(salary)) 급여평균, 
			max(salary) 최대급여, 
			min(salary) 최소급여 
		from employees 
		where department_id is not null 
		group by department_id 
		having count(*) > 1 
		order by count(*) desc
	*/	
	
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dbUrl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbUser = "hr";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println(conn);
	
	String sql = "select department_id 부서ID, count(*) 부서인원, sum(salary) 급여합계, round(avg(salary)) 급여평균, max(salary) 최대급여, min(salary) 최소급여 "
				+ "from employees where department_id is not null group by department_id having count(*) > 1 order by count(*) desc";
	PreparedStatement stmt = conn.prepareStatement(sql);
	System.out.println(stmt);
	ResultSet rs = stmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>(); 
	// 한 줄에 같은 제너릭이 두번 나오면 뒤의 제너릭은 생략가능 -> new ArrayList<>
	while(rs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("부서ID", rs.getInt("부서ID"));
		m.put("부서인원", rs.getInt("부서인원"));
		m.put("급여합계", rs.getInt("급여합계"));
		m.put("급여평균", rs.getInt("급여평균"));
		m.put("최대급여", rs.getInt("최대급여"));
 		m.put("최소급여", rs.getInt("최소급여"));
		list.add(m);
	}
	System.out.println(list);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Employees table GROUP BY Test</title>
</head>
<body>
	<table border="1">
		<tr>
			<td>부서ID</td>
			<td>부서인원</td>
			<td>급여합계</td>
			<td>급여평균</td>
			<td>최대급여</td>
			<td>최소급여</td>
		</tr>
		<%
			for(HashMap<String, Object> m : list){
		%>
				<tr>
					<td><%=(Integer)(m.get("부서ID"))%></td>
					<td><%=(Integer)(m.get("부서인원"))%></td>
					<td><%=(Integer)(m.get("급여합계"))%></td>
					<td><%=(Integer)(m.get("급여평균"))%></td>
					<td><%=(Integer)(m.get("최대급여"))%></td>
					<td><%=(Integer)(m.get("최소급여"))%></td>
				</tr>
		<%
			}
		%>
	</table>
</body>
</html>