<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ include file="../common/header.jsp" %>

<h2 class="page-title">
    <c:choose>
        <c:when test="${bookForm.id != null}">書籍編集</c:when>
        <c:otherwise>書籍登録</c:otherwise>
    </c:choose>
</h2>

<div class="card">
    <s:actionerror cssClass="alert-error"/>

    <c:choose>
        <c:when test="${bookForm.id != null}">
            <s:form action="edit" namespace="/book" method="POST" theme="simple">
                <s:hidden name="bookForm.id"/>
        </c:when>
        <c:otherwise>
            <s:form action="create" namespace="/book" method="POST" theme="simple">
        </c:otherwise>
    </c:choose>

        <div class="form-group">
            <label>タイトル <span style="color:red;">*</span></label>
            <s:textfield name="bookForm.title" value="%{bookForm.title}"/>
            <s:fielderror fieldName="bookForm.title" cssClass="error-message" theme="simple"/>
        </div>

        <div class="form-group">
            <label>著者 <span style="color:red;">*</span></label>
            <s:textfield name="bookForm.author" value="%{bookForm.author}"/>
            <s:fielderror fieldName="bookForm.author" cssClass="error-message" theme="simple"/>
        </div>

        <div class="form-group">
            <label>ISBN（13桁）<span style="color:red;">*</span></label>
            <s:textfield name="bookForm.isbn" value="%{bookForm.isbn}"/>
            <s:fielderror fieldName="bookForm.isbn" cssClass="error-message" theme="simple"/>
        </div>

        <div class="form-group">
            <label>カテゴリ <span style="color:red;">*</span></label>
            <s:select name="bookForm.category" value="%{bookForm.category}"
                      list="#{'NOVEL':'小説','TECH':'技術書','REFERENCE':'参考書','OTHER':'その他'}"
                      headerKey="" headerValue="-- 選択してください --"/>
            <s:fielderror fieldName="bookForm.category" cssClass="error-message" theme="simple"/>
        </div>

        <div class="form-group">
            <label>出版年</label>
            <s:textfield name="bookForm.publishedYear" value="%{bookForm.publishedYear}"/>
            <s:fielderror fieldName="bookForm.publishedYear" cssClass="error-message" theme="simple"/>
        </div>

        <div style="margin-top:16px;">
            <button type="submit" class="btn btn-primary">
                <c:choose>
                    <c:when test="${bookForm.id != null}">更新する</c:when>
                    <c:otherwise>登録する</c:otherwise>
                </c:choose>
            </button>
            <a href="<s:url action='list' namespace='/book'/>" class="btn btn-secondary">キャンセル</a>
        </div>

    </s:form>
</div>

<%@ include file="../common/footer.jsp" %>
