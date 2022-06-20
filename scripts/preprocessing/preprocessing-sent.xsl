<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:telota="http://www.telota.de" exclude-result-prefixes="#all" version="2.0">
    <xsl:param name="INPUT_DIR"/>

    <xsl:template match="/">
        
        <xsl:variable name="input-cleaned" select="replace($INPUT_DIR, '\\', '/')" as="xs:string"/>
        <xsl:variable name="output-cleaned" select="replace($input-cleaned, 'data-source/cab2', 'data-analysis')" as="xs:string"/>
        
        <xsl:variable name="input-dir-uri" select="'file:///' || $input-cleaned || '?recurse=yes;select=*.xml'" as="xs:string"/>
        
        <xsl:variable name="output-uri" select="'file:///' || $output-cleaned"/> 
        
        <xsl:variable name="documents" as="document-node()*" select="collection($input-dir-uri)"/>

     

        <!-- for sentiment analysis; group by correspondent -->
     <!--   <xsl:for-each-group select="$documents//tei:TEI"
            group-by="//tei:correspAction[@type = 'sent']/tei:persName/@key">
            <xsl:variable name="filename" select="current-grouping-key()"/>            
            <xsl:variable name="name" select="distinct-values(current-group()//tei:correspAction[@type = 'sent']/tei:persName[@key = current-grouping-key()])"/>
            <xsl:result-document href="{$output-uri || 'data-analysis/corresp-sent/' ||  replace($name, ' ', '-') || '_' || $filename  || '.txt'}"
                method="text" indent="no" media-type="text">
                <xsl:apply-templates select="//tei:text"/>
            </xsl:result-document>
        </xsl:for-each-group>-->
        
        <!-- for sentiment analysis; group by year -->
        
   <!--     <xsl:for-each-group select="$documents//tei:TEI"
            group-by="//tei:correspAction[@type = 'sent']/tei:date/(@when | @notBefore | @from)[1]/substring(., 1, 4)">
            <xsl:variable name="filename" select="current-grouping-key()"/>
            <xsl:result-document href="{$output-uri || 'data-analysis/date-sent/' || $filename || '.txt'}"
                method="text" indent="no" media-type="text">
                <xsl:apply-templates select="//tei:text"/>
            </xsl:result-document>
        </xsl:for-each-group>-->
        

        
       <!-- Themen, denen mindestens 30 Briefe zugeordnet wurden --> 
           
        <xsl:for-each-group select="$documents//tei:TEI"
            group-by="//tei:keywords[@scheme = '#topics']/tei:term">
            <xsl:variable name="id" select="current-grouping-key()"/>
            <xsl:if test="count(current-group()) &gt; 29">
            <xsl:result-document href="{$output-uri || '/sentiment/topics-min30/' || translate($id, ' /', '-') || '.txt'}"
                method="text" indent="no" media-type="text">
                <xsl:apply-templates select="current-group()/tei:text"/>
            </xsl:result-document>
            </xsl:if>
        </xsl:for-each-group>
        
        <!-- Alle themen -->
        <xsl:for-each-group select="$documents//tei:TEI"
            group-by="//tei:keywords[@scheme = '#topics']/tei:term">
            <xsl:variable name="id" select="current-grouping-key()"/>
          
                <xsl:result-document href="{$output-uri || '/sentiment/topics-all/' || translate($id, ' /', '-') || '.txt'}"
                    method="text" indent="no" media-type="text">
                    <xsl:apply-templates select="current-group()/tei:text"/>
                </xsl:result-document>
            
        </xsl:for-each-group>
        
        <!-- for sentiment analysis of specific keywords;  -->
        
        <xsl:for-each-group select="$documents//tei:TEI" group-by="//tei:keywords[@scheme = '#topics']/tei:term">
            <xsl:variable name="folder" select="replace(current-grouping-key(), ' ', '-')"/>
            <xsl:for-each-group select="current-group()" group-by="//tei:correspAction[@type = 'sent']/tei:date/(@when | @notBefore | @from)[1]/substring(., 1, 4)">
            <xsl:variable name="file" select="current-grouping-key()"/>
            <xsl:result-document href="{$output-uri || '/sentiment/topic-groups/' || distinct-values($folder || '/' || $file || '.txt')}"
                method="text" indent="no" media-type="text">
                <xsl:apply-templates select="current-group()/tei:text"/>
            </xsl:result-document>
            </xsl:for-each-group>
        </xsl:for-each-group>
        
       <!-- <xsl:for-each-group select="$documents//tei:TEI[//tei:keywords[@scheme = '#topics']/tei:term[@xml:id='JP-012486']]"
            group-by="//tei:correspAction[@type = 'sent']/tei:date/(@when | @notBefore | @from)[1]/substring(., 1, 4)">
            <xsl:variable name="id" select="current-grouping-key()"/>
            <xsl:result-document href="{$output-uri || '/sentiment/topic-groups/' || distinct-values(current-group()//tei:keywords[@scheme = '#topics']/tei:term[@xml:id='JP-012601']) || '/' || replace($id, ' ', '-') || '.txt'}"
                method="text" indent="no" media-type="text">
                <xsl:apply-templates select="current-group()//@word"/>
            </xsl:result-document>
        </xsl:for-each-group>-->
        
    </xsl:template>

    <xsl:template match="tei:text">
        <xsl:apply-templates select="normalize-space()"/>
    </xsl:template>




</xsl:stylesheet>
