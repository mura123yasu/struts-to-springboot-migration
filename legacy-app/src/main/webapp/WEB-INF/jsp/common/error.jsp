<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ include file="header.jsp" %>

<div class="card">
    <h2 class="page-title">エラー</h2>
    <div class="alert-error">
        <s:actionerror/>
        <c:if test="${empty actionErrors}">
            予期しないエラーが発生しました。
        </c:if>
    </div>
    <a href="<s:url action='list' namespace='/book'/>" class="btn btn-secondary">書籍一覧へ戻る</a>
</div>

<%@ include file="footer.jsp" %>
