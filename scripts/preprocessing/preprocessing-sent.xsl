<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:telota="http://www.telota.de" exclude-result-prefixes="#all" version="2.0">
    
    <!-- 
        Stylesheet is executed by preprocessing-sent.bat
        Generates collections for sentiment analysis with Sent Text; adapted to CAB-data
        @author: Frederike Neuber
    -->
    
    <xsl:param name="INPUT_DIR"/>

    <xsl:template match="/">
        <!-- Preparing paths for getting/saving input and output data -->
        <xsl:variable name="input-cleaned" select="replace($INPUT_DIR, '\\', '/')" as="xs:string"/>   
        <xsl:variable name="output-cleaned"
            select="replace($input-cleaned, 'data-source/cab-umfeldbriefe', 'data-analysis/sentiment')"
            as="xs:string"/>
        <xsl:variable name="input-dir-uri"
            select="'file:///' || $input-cleaned || '?recurse=yes;select=*.xml'" as="xs:string"/>
        <xsl:variable name="output-uri" select="'file:///' || $output-cleaned"/>
        <xsl:variable name="documents" as="document-node()*" select="collection($input-dir-uri)"/>

        <!-- Gathers letters by senders which have written at least 20 letters in a single txt file -->
        
        <xsl:for-each-group select="$documents//tei:TEI"
            group-by="//tei:correspAction[@type = 'sent']/tei:persName/@key">
            <xsl:variable name="filename" select="current-grouping-key()"/>
            <xsl:variable name="name"
                select="distinct-values(current-group()//tei:correspAction[@type = 'sent']/tei:persName[@key = current-grouping-key()])"/>
            <xsl:if test="count(current-group()) &gt; 19">
                <xsl:result-document
                    href="{$output-uri || '/sender-min20/' ||  replace($name, ' ', '-') || '_' || $filename  || '.txt'}"
                    method="text" indent="no" media-type="text">
                    <xsl:apply-templates select="current-group()//@word"/>
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each-group>
        
        <!-- Creates a colltextion of the letters by Friedrich Arnold Brockhaus as txt -->
        
        <xsl:for-each
            select="$documents//tei:TEI[//tei:correspAction[@type = 'sent']/tei:persName/@key = 'JP-000501']">
            <xsl:variable name="file"
                select="concat(//tei:correspAction[@type = 'sent']/tei:date/(@when | @notBefore | @from)[1], '_', //tei:correspAction[@type = 'received']/tei:persName[1]/translate(., ' ', ''))"/>
            <xsl:result-document href="{$output-uri || '/f_a_brockhaus/' || $file || '.txt'}"
                method="text" indent="no" media-type="text">
                <xsl:apply-templates select="//@word"/>
            </xsl:result-document>
        </xsl:for-each>
        
    </xsl:template>
    
    <!-- Chooses the normalized version of word -->

    <xsl:template match="@word">
        <xsl:value-of select=". || ' '"/>
    </xsl:template>

</xsl:stylesheet>
