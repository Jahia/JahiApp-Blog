<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="uiComponents" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<template:addResources type="css" resources="blog.css"/>
<template:addResources type="css" resources="tagged.css"/>
<template:addResources type="css" resources="jquery-ui.smoothness.css"/>
<template:addResources type="css" resources="autocompletefix.css"/>
<template:addResources type="javascript" resources="jquery.min.js,jquery.jeditable.js,jquery-ui.min.js"/>
<template:addResources type="javascript" resources="blogEntry.js"/>
<jcr:nodeProperty node="${renderContext.mainResource.node}" name="jcr:title" var="title"/>
<jcr:nodeProperty node="${renderContext.mainResource.node}" name="text" var="text"/>
<jcr:nodeProperty node="${renderContext.mainResource.node}" name="jcr:createdBy" var="createdBy"/>
<jcr:nodeProperty node="${renderContext.mainResource.node}" name="jcr:created" var="created"/>
<uiComponents:ckeditor selector="addContent">
{
   height : 300
}
</uiComponents:ckeditor>

<script type="text/javascript">
    $(document).ready(function(){
        function split( val ) {
            return val.split( /,\s*/ );
        }
        function extractLast( term ) {
            return split( term ).pop();
        }

        $(".addTag").bind( "keydown", function( event ) {
            if ( event.keyCode === $.ui.keyCode.TAB &&
                    $( this ).data( "ui-autocomplete" ).menu.active ) {
                event.preventDefault();
            }
        }).autocomplete({
            autofocus:true,
            source:function( request, response ) {
                $.ajax({
                    url: "<c:url value='${url.base}${renderContext.mainResource.node.path}.matchingTags.do'/>",
                    dataType: "json",
                    data: {
                        path: "${renderContext.mainResource.node.path}",
                        limit: 10,
                        q: extractLast( request.term )
                    },
                    success: function( data ) {
                        response( $.map( data.tags, function( item ) {
                            return {
                                label: item.name,
                                value: item.name
                            }
                        }));
                    }
                });
            },
            focus: function() {
                // prevent value inserted on focus
                return false;
            },
            select: function( event, ui ) {
                var terms = split( this.value );
                // remove the current input
                terms.pop();
                // add the selected item
                terms.push( ui.item.value );
                // add placeholder to get the comma-and-space at the end
                terms.push( "" );
                this.value = terms.join( ", " );
                return false;
            }
        });
    });
</script>
    <template:tokenizedForm>
        <form id="formPost" method="post" action="<c:url value='${url.base}${functions:escapePath(renderContext.mainResource.node.path)}.addBlogEntry.do'/>" name="blogPost">
            <input type="hidden" name="jcrNodeType" value="jnt:blogPost"/>
            <input type="hidden" name="jcrNormalizeNodeName" value="true"/>
            <input type="hidden" name="jcrParentType" value="jnt:blogPosts"/>
            <fmt:formatDate value="${created.time}" type="date" pattern="dd" var="userCreatedDay"/>
            <fmt:formatDate value="${created.time}" type="date" pattern="MMM" var="userCreatedMonth"/>
            <p class="post-info"><fmt:message key="blog.label.by"/>&nbsp;${createdBy.string}
                &nbsp;-&nbsp;<fmt:formatDate value="${created.time}" type="date" dateStyle="medium"/>
            </p>

            <p>
                <label><fmt:message key="title"/> </label>
                <input type="text" value="" name="jcr:title"/>
            </p>

            <div class="post-content">
                <label><fmt:message key="blog.post"/> </label>
                <textarea name="text" rows="10" cols="70" id="addContent"></textarea>

                <br>
                <p>
                    <ul class="post-tags">

                    </ul>
                </p>
                <p>
                    <label><fmt:message key="blog.label.tag"/>:&nbsp;</label>
                    <input type="text" value="" style="width: 220px" class="addTag"/>
                    <input type="button" class="button" value="<fmt:message key='label.add'/>" onclick="addTag()"/>
                </p>

                <p>
                    <fmt:message key='jnt_blog.noTitle' var="noTitle"/>
                    <input class="button"
                           type="button"
                           tabindex="16"
                           value="<fmt:message key='label.save'/>"
                           onclick="
                        if (document.blogPost.elements['jcr:title'].value == '') {
                            alert('${fn:replace(noTitle,"'","\\'")}');
                            return false;
                        }
                        <%--document.blogPost.action = '${renderContext.mainResource.node.name}/blog-content/' + encodeURIComponent(document.blogPost.elements['jcr:title'].value);--%>
                        document.blogPost.submit();"/>
                </p>
            </div>
        </form>
    </template:tokenizedForm>
