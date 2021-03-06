<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="user" uri="http://www.jahia.org/tags/user" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="propertyDefinition" type="org.jahia.services.content.nodetypes.ExtendedPropertyDefinition"--%>
<%--@elvariable id="type" type="org.jahia.services.content.nodetypes.ExtendedNodeType"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<template:addResources type="css" resources="blog.css"/>
	
<jcr:nodeProperty node="${currentNode}" name="jcr:title" var="title"/>
<jcr:nodeProperty node="${currentNode}" name="text" var="text"/>
<jcr:nodeProperty node="${currentNode}" name="jcr:createdBy" var="createdBy"/>
<jcr:nodeProperty node="${currentNode}" name="jcr:created" var="created"/>
	
<c:set var="currentUser" value="${user:lookupUser(createdBy.string)}"/>

<fmt:formatDate value="${created.time}" type="date" pattern="dd" var="userCreatedDay"/>
<fmt:formatDate value="${created.time}" type="date" pattern="MMM" var="userCreatedMonth"/>
<c:if test="${jcr:isNodeType(currentNode, 'jnt:blogPost')}">
    <c:set var="blogHome" value="${url.base}${currentResource.node.parent.path}.html"/>
</c:if>
<c:if test="${!jcr:isNodeType(currentNode, 'jnt:blogPost')}">
    <c:set var="blogHome" value="${url.current}"/>
</c:if>

<c:set var="canDelete" value="${jcr:hasPermission(currentNode,'deleteBlogEntry') && renderContext.readOnlyStatus eq 'OFF'}"/>
<c:set var="canEdit" value="${jcr:hasPermission(currentNode,'editBlogEntry') && renderContext.readOnlyStatus eq 'OFF'}"/>

<c:if test="${canDelete}">
    <template:tokenizedForm>
    <form action="<c:url value='${url.base}${currentNode.path}'/>" method="post"
          id="jahia-blog-article-delete-${currentNode.UUID}">
        <input type="hidden" name="jcrRedirectTo" value="<c:url value='${url.base}${jcr:getParentOfType(renderContext.mainResource.node, "jnt:page").path}'/>"/>
            <%-- Define the output format for the newly created node by default html or by jcrRedirectTo--%>
        <input type="hidden" name="jcrNewNodeOutputFormat" value="html"/>
        <input type="hidden" name="jcrMethodToCall" value="delete"/>
    </form>
    </template:tokenizedForm>
</c:if>

<div class="post">
    <c:if test="${canEdit or canDelete}">
        <span class="posteditdelete">
            <c:if test="${canDelete}">
            <a class="postdelete"  href="#" onclick="document.getElementById('jahia-blog-article-delete-${currentNode.UUID}').submit();"><fmt:message key="blog.label.delete"/></a>
            </c:if><c:if test="${canEdit}">
            <a class="postedit" href="<c:url value='${url.base}${currentResource.node.path}.blog-edit.html'/>"><fmt:message key="blog.label.edit"/></a>
            </c:if>
        </span>
    </c:if>
    <div class="post-date"><span>${userCreatedMonth}</span>${userCreatedDay}</div>
    <h2 class="post-title"><c:out value="${title.string}"/></h2>

    <c:set var="fields" value="${currentUser.propertiesAsString}"/>
    <p class="post-info"><fmt:message key="blog.label.by"/>&nbsp;${user:fullName(currentUser)}&nbsp;-&nbsp;<fmt:formatDate value="${created.time}" type="date" dateStyle="medium"/></p>
    <ul class="post-tags">
        <jcr:nodeProperty node="${currentNode}" name="j:tagList" var="assignedTags"/>
        <c:forEach items="${assignedTags}" var="tag" varStatus="status">
            <li>${fn:escapeXml(tag.string)}</li>
        </c:forEach>
    </ul>
    <div class="post-content">
        ${text.string}
    </div>
    <jcr:sql var="numberOfPostsQuery"
             sql="select [jcr:uuid] from [jnt:post] as p  where isdescendantnode(p,['${currentNode.path}'])"/>
    <c:set var="numberOfPosts" value="${numberOfPostsQuery.rows.size}"/>
    <p class="post-info-links">
        <c:if test="${numberOfPosts == 0}">
            <a class="comment_count" href="<c:url value='${url.current}#comments'/>">0&nbsp;<fmt:message key="blog.label.comments"/></a>
        </c:if>
        <c:if test="${numberOfPosts > 0}">
            <a class="comment_count" href="<c:url value='${url.current}#comments'/>">${numberOfPosts}&nbsp;<fmt:message key="blog.label.comments"/></a>
        </c:if>
    </p>
 <div class="clear"></div>
</div>
<template:addCacheDependency path="${currentNode.path}/comments"/>
