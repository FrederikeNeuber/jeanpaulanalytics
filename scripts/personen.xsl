<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:telota="http://www.telota.de" exclude-result-prefixes="#all" version="2.0">
    
    <!-- 
    @author: Frederike Neuber

    -->
    
    <!-- Input directory as defined in personen.bat -->
    <xsl:param name="INPUT_DIR"/>
    
    <xsl:template match="/">
        <!-- Preparing Paths for getting/saving input and output data -->
        <xsl:variable name="input-cleaned" select="replace($INPUT_DIR, '\\', '/')" as="xs:string"/>
        <xsl:variable name="output-cleaned"
            select="replace($input-cleaned, 'data-preprocessed/letters-xml', 'results/')"
            as="xs:string"/>
        
        <!-- Defines input XML collection -->
        <xsl:variable name="input-dir-uri"
            select="'file:///' || $input-cleaned || '?recurse=yes;select=*.xml'" as="xs:string"/>
        <xsl:variable name="documents" select="collection($input-dir-uri)" as="document-node()*"/>
        
        <!-- Defines output file -->
        <xsl:variable name="output-uri-csv-1"
            select="'file:///' || $output-cleaned || 'reichweite.txt'" as="xs:string"/>
       <!-- <xsl:variable name="output-uri-csv-2"
            select="'file:///' || $output-cleaned || 'correspondents-message-coverage.txt'"
            as="xs:string"/>
        <xsl:variable name="output-uri-csv-3"
            select="'file:///' || $output-cleaned || 'correspondents-year.txt'" as="xs:string"/>
        <xsl:variable name="output-uri-csv-4"
            select="'file:///' || $output-cleaned || 'correspondents-roles.txt'" as="xs:string"/>
    -->    
        <!-- CSV variables -->
        
        <xsl:variable name="s" select="';'"/>
        <xsl:variable name="l" select="'&#10;'"/>
        
        <!-- variables for queries -->
        
        <xsl:variable name="all-letters"
            select="count(//$documents//tei:TEI)"/>
        <xsl:variable name="all-length"
            select="sum(//$documents/string-length(//tei:text))"/>
        <xsl:variable name="all-correspondents"
            select="count($documents//tei:correspAction[@type = 'sent' or @type = 'received']//tei:persName/@key)"/>
        <xsl:variable name="all-readers"
            select="count($documents//tei:correspAction[@type = 'read']//tei:persName/@key)"/>
        <xsl:variable name="all-commentors"
            select="count($documents//tei:text//@hand[. != '#author'])"/>
        <xsl:variable name="all-mentions"
            select="count($documents//tei:text//tei:persName/@key)"/>
        <xsl:variable name="single-topics"
            select="count(distinct-values($documents//tei:keywords[@scheme = '#topics']/tei:term))"/>
        <xsl:variable name="single-circle"
            select="count(distinct-values($documents//tei:keywords[@scheme = '#correspondents']/tei:term))"/>
        
        <!-- correspondents-roles.txt -->
        
         <!-- reichweite.txt -->
        
        <xsl:result-document href="{$output-uri-csv-1}" method="text">
            <xsl:value-of
                select="'Korrespondent/innen' || $s || 'Summe aller Personenkontakte' || $s || 'Erreichte Personen' || $l"/>
            <xsl:for-each-group select="$documents//tei:correspAction[@type = 'sent']/tei:persName"
                group-by="@key">
                <xsl:sort select="count(current-group())" data-type="number" order="descending"/>
                <xsl:variable name="person" select="distinct-values(current-group())"/>
                <xsl:variable name="brw"
                    select="count(current-group()/following::tei:correspAction[@type = 'received' or @type = 'read']/tei:persName/@key)"/>
                <xsl:variable name="nrw"
                    select="count(distinct-values(current-group()/following::tei:correspAction[@type = 'received' or @type = 'read']/tei:persName/@key))"/>
                <xsl:variable name="drw" select="number($brw div $nrw)"/>
                <xsl:value-of select="$person || $s || $brw || $s || $nrw || $l"/>
            </xsl:for-each-group>
        </xsl:result-document>
        
      
        
    </xsl:template>
    
</xsl:stylesheet>
