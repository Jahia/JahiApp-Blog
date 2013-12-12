<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="uiComponents" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%@ taglib prefix="user" uri="http://www.jahia.org/tags/user" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<jcr:nodeProperty node="${renderContext.mainResource.node}" name="jcr:title" var="title"/>
<jcr:nodeProperty node="${renderContext.mainResource.node}" name="text" var="text"/>
<jcr:nodeProperty node="${renderContext.mainResource.node}" name="jcr:createdBy" var="createdBy"/>
<jcr:nodeProperty node="${renderContext.mainResource.node}" name="jcr:created" var="created"/>
<template:addResources type="css" resources="blog.css"/>
<template:addResources type="javascript" resources="jquery.min.js,jquery.jeditable.js"/>

<jcr:nodeProperty node="${renderContext.mainResource.node}" name="j:tags" var="assignedTags"/>
<c:set var="tags" value=""/>
<c:forEach items="${assignedTags}" var="tag" varStatus="status">
    <c:set var="tags" value="${tags}${tag.node.name}${!status.last ? ',' : ''}"/>
</c:forEach>
<c:url var="postUrl" value="${url.base}${renderContext.mainResource.node.path}"/>
<script type="text/javascript">
    $(document).ready(function() {
        $.each(['editContent'], function(index, element) {
            if ($('#' + element).length > 0) {
                $('label[for="' + element + '"]').hide();
            }
        });
    });

    function submitBlogPost(){
        // remove tags
        <c:choose>
        <c:when test="${not empty tags}">
        var initialTags = "${tags}".split(',');
        </c:when>
        <c:otherwise>
        var initialTags = [];
        </c:otherwise>
        </c:choose>
        var tags = $(".tags").val().split(',');
        var tagsToRemove = [];
        $.each(initialTags, function(i, initialTag){
            if($.inArray(initialTag, tags) == -1){
                tagsToRemove.push(initialTag);
            }
        });

        var options = {
            url: "${postUrl}.removeTag.do",
            type: "POST",
            dataType: "json",
            data: {"tag":tagsToRemove},
            traditional: true
        };

        $.ajax(options)
                .done(function (result) {
                    // tag successfully deleted, save the form
                    document.blogPost.submit();
                });

        return false;
    }
</script>
<uiComponents:ckeditor selector="editContent">
{
   height : 300
}
</uiComponents:ckeditor>
   <template:tokenizedForm>
    <form id="formPost" method="post" action="<c:url value='${url.base}${functions:escapePath(renderContext.mainResource.node.path)}/'/>" name="blogPost">
        <input type="hidden" name="jcrAutoCheckin" value="true">
        <input type="hidden" name="jcrNodeType" value="jnt:blogPost">
        <fmt:formatDate value="${created.time}" type="date" pattern="dd" var="userCreatedDay"/>
        <fmt:formatDate value="${created.time}" type="date" pattern="mm" var="userCreatedMonth"/>
        <p class="post-info"><fmt:message key="blog.label.by"/>&nbsp;<a href="<c:url value='${url.base}${user:lookupUser(createdBy.string).localPath}.html'/>">${createdBy.string}</a>
           &nbsp;-&nbsp;<fmt:formatDate value="${created.time}" type="date" dateStyle="medium"/>
        </p>
		<p>
	    	<label><fmt:message key="title"/> </label>
			<input type="text" value="<c:out value='${title.string}'/>" name="jcr:title"/>
        </p>

        <div class="post-content">
        	<label><fmt:message key="blog.post"/> </label>
                <textarea name="text" rows="10" cols="70" id="editContent">
                    ${fn:escapeXml(text.string)}
                </textarea>
            
            <ul class="post-tags">
                <c:forEach items="${assignedTags}" var="tag" varStatus="status">
                    <li>${tag.node.name}</li>
                </c:forEach>
            </ul>
			<p>
                <label><fmt:message key="blog.label.tag"/>:&nbsp;</label>
                <input type="text" class="tags" name="j:newTag" value="${tags}"/>
            </p>
            <p>
                <input
                        class="button"
                        type="button"
                        tabindex="16"
                        value="<fmt:message key='blog.label.save'/>"
                        onclick="submitBlogPost()"
                        />
            </p>
        </div>
    </form>
   </template:tokenizedForm>