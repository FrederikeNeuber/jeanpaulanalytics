<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:telota="http://www.telota.de" exclude-result-prefixes="#all" version="2.0">
    <xsl:param name="INPUT_DIR"/>

    <!-- 
    @author: Frederike Neuber
    --> 

    <xsl:template match="/">
        
        <!-- Preparing Paths for getting/saving input and output data -->
        <xsl:variable name="input-cleaned" select="replace($INPUT_DIR, '\\', '/')" as="xs:string"/>
        <xsl:variable name="output-cleaned" select="replace($input-cleaned, 'data-preprocessed/letters-xml', 'results/')" as="xs:string"/>
        
        <!-- Defines input XML collection -->
        <xsl:variable name="input-dir-uri"
            select="'file:///' || $input-cleaned || '?recurse=yes;select=*.xml'" as="xs:string"/>
        <xsl:variable name="documents" as="document-node()*" select="collection($input-dir-uri)"/>
        
        <!-- Defines output file --> 
        <xsl:variable name="output-uri-1"
            select="'file:///' || $output-cleaned || 'network.txt'"/>
        <xsl:variable name="output-uri-2"
            select="'file:///' || $output-cleaned || 'network-circles.txt'"/>

        <!-- CSV notation variables -->
        <xsl:variable name="s" select="';'"/>
        <xsl:variable name="l" select="'&#10;'"/>
        

        <xsl:result-document href="{$output-uri-1}" method="text">
            <xsl:value-of select="'Korrespondent/in 1' || $s || 'Korrespondent/in 2' || $s || 'Briefe' || $l"/>
            <xsl:for-each-group
                select="$documents//tei:correspDesc"
                group-by="tei:correspAction[@type = 'sent']/tei:persName">    
                <xsl:variable name="sender" select="current-grouping-key()"/>
                    <xsl:for-each-group
                        select="current-group()"
                        group-by="tei:correspAction[@type = 'received']/tei:persName">
                        <xsl:value-of select="$sender || $s || current-grouping-key() || $s || count(current-group()) || $l"/>  
                    </xsl:for-each-group>                   
            </xsl:for-each-group>            
        </xsl:result-document>
        
<!--        matrix rawgraphs-->
            <xsl:result-document href="{$output-uri-2}" method="text">
                <xsl:value-of select="'Kreis' || $s || 'Korrespondent/in' || $s || 'Briefe' || $l"/>
                <xsl:for-each-group
                    select="$documents//tei:TEI//tei:keywords[@scheme='#correspondents']"
                    group-by="tei:term">    
                    <xsl:sort select="count(current-group())" order="descending"></xsl:sort>
                    <xsl:variable name="topic" select="current-grouping-key()"/>
                    <xsl:if test="count(current-group()) gt 20">
                    <xsl:for-each-group
                        select="current-group()"
                        group-by="preceding::tei:correspDesc//tei:persName">
                        <xsl:value-of select="$topic || $s || current-grouping-key() || $s || count(current-group()) || $l"/>  
                    </xsl:for-each-group>   
                    </xsl:if>
                </xsl:for-each-group>       
        </xsl:result-document>
    </xsl:template>
    
</xsl:stylesheet>
