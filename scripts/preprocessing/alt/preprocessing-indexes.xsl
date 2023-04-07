<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:telota="http://www.telota.de" exclude-result-prefixes="#all" version="2.0">
    
    <!-- 
        reduces the TEI files of the indexes to contents needed for analysis 
        @author: Frederike Neuber
    -->
    
    <xsl:param name="INPUT_DIR"/>

    <xsl:strip-space elements="*"/>

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
        <!-- config with .bat file -->
        <xsl:variable name="input-dir-uri"
            select="'file:///' || replace($INPUT_DIR, '\\', '/') || '?recurse=yes;select=*.xml'"
            as="xs:string"/>
        <xsl:variable name="documents" as="document-node()*" select="collection($input-dir-uri)"/>
        
        <xsl:for-each select="$documents">
            <xsl:variable name="cur-doc" select="." as="document-node()"/>
            <xsl:variable name="basename" as="xs:string" select="string(base-uri($cur-doc))"/>
            <!-- modify path to data source as needed -->
            <xsl:variable name="output-uri"
                select="replace($basename, 'data-source/register/', 'data-preprocessed/indexes/')"/>
            <xsl:result-document href="{$output-uri}">
                <xsl:apply-templates select="$cur-doc/node()"/>
            </xsl:result-document>
        </xsl:for-each>

    </xsl:template>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>
