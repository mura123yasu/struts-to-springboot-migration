<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ include file="../common/header.jsp" %>

<h2 class="page-title">書籍詳細</h2>

<div class="card">
    <dl>
        <dt>ID</dt>
        <dd>${book.id}</dd>
        <dt>タイトル</dt>
        <dd>${book.title}</dd>
        <dt>著者</dt>
        <dd>${book.author}</dd>
        <dt>ISBN</dt>
        <dd>${book.isbn}</dd>
        <dt>カテゴリ</dt>
        <dd>${book.category}</dd>
        <dt>出版年</dt>
        <dd>${book.publishedYear}</dd>
        <dt>登録日時</dt>
        <dd>${book.createdAt}</dd>
        <dt>更新日時</dt>
        <dd>${book.updatedAt}</dd>
    </dl>

    <div style="margin-top:24px;">
        <a href="<s:url action='list' namespace='/book'/>" class="btn btn-secondary">一覧へ戻る</a>
        <c:if test="${sessionScope.loginUser != null}">
            <a href="<s:url action='edit' namespace='/book'/>?id=${book.id}" class="btn btn-warning">編集</a>
            <s:form action="delete" namespace="/book" method="POST" theme="simple" style="display:inline;">
                <s:hidden name="id" value="%{book.id}"/>
                <button type="submit" class="btn btn-danger"
                        onclick="return confirm('削除してよろしいですか？')">削除</button>
            </s:form>
        </c:if>
    </div>
</div>

<%@ include file="../common/footer.jsp" %>
