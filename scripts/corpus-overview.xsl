<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:telota="http://www.telota.de" exclude-result-prefixes="#all" version="2.0">
    <xsl:param name="INPUT_DIR"/>
       
    <!-- 
    @author: Frederike Neuber
    -->
    
    <!--
    Creates a table with basic information (in numbers) about the corpus.
    -->

    <xsl:template match="/">
        
        <!-- Paths for input/output data -->
        
        <xsl:variable name="input-cleaned" select="replace($INPUT_DIR, '\\', '/')" as="xs:string"/>
        <xsl:variable name="output-cleaned"
            select="replace($input-cleaned, 'data-preprocessed/letters-xml', 'results/')"
            as="xs:string"/>
        <xsl:variable name="input-dir-uri"
            select="'file:///' || $input-cleaned || '?recurse=yes;select=*.xml'" as="xs:string"/>
        <xsl:variable name="documents" as="document-node()*" select="collection($input-dir-uri)"/>
        <xsl:variable name="output-uri-1"
            select="'file:///' || $output-cleaned || 'corpus-overview.txt'"/>
        <xsl:variable name="output-uri-2"
            select="'file:///' || $output-cleaned || 'corpus-overview-extended.txt'"/>

        <!-- CSV variables -->
        
        <xsl:variable name="s" select="';'"/>
        <xsl:variable name="l" select="'&#10;'"/>

        <!-- Variables for queries -->
        
        <xsl:variable name="min-date"
            select="min(//$documents//tei:correspAction[@type = 'sent']/tei:date/(@when | @from)/xs:date(.))"/>
        <xsl:variable name="max-date"
            select="max(//$documents//tei:correspAction[@type = 'sent']/tei:date/(@when | @to | @notAfter)/xs:date(.))"/>
        <xsl:variable name="max-length" select="max(//$documents/string-length(//tei:text))"/>
        <xsl:variable name="min-length" select="min(//$documents/string-length(//tei:text))"/>

        <!-- corpus-overview.txt -->
        
        <xsl:result-document href="{$output-uri-1}" method="text">
            <xsl:value-of select="'Alle Briefe' || $s || count($documents//tei:TEI) || $l"/>
            <xsl:value-of
                select="'Alle Briefe in Zeichen' || $s || sum(//$documents/string-length(//tei:text)) || $l"/>
            <xsl:value-of
                select="'Korrespondent/innen' || $s || count(distinct-values($documents//tei:correspAction[not(@type = 'read')]/tei:persName/@key)) || $l"/>
            <xsl:value-of
                select="'Mitleser/innen' || $s || count(distinct-values($documents//tei:correspAction[@type = 'read']/tei:persName/@key)) || $l"/>
            <xsl:value-of
                select="'Kommentator/innen' || $s || count(distinct-values($documents//tei:text//@hand[. != '#author' or not(preceding::tei:correspAction[@type = 'sent']/tei:persName/@key)])) || $l"/>
            <xsl:value-of
                select="'Annotierte Korrespondenzkreise' || $s || count(distinct-values($documents//tei:keywords[@scheme = '#correspondents']/tei:term/@xml:id)) || $l"/>
            <xsl:value-of
                select="'Summe annotierte Korrespondenzkreise' || $s || count($documents//tei:keywords[@scheme = '#correspondents']/tei:term/@xml:id) || $l"/>
            <xsl:value-of
                select="'Annotierte Themen' || $s || count(distinct-values($documents//tei:keywords[@scheme = '#topics']/tei:term/@xml:id)) || $l"/>
            <xsl:value-of
                select="'Summe annotierte Themen' || $s || count($documents//tei:keywords[@scheme = '#topics']/tei:term/@xml:id) || $l"/>
            <xsl:value-of
                select="'Indizierungen' || $s || count(distinct-values($documents//tei:text//tei:persName/(@key | @sameAS))) || $l"/>
            <xsl:value-of
                select="'Summe alle Indizierungen' || $s || count($documents//tei:text//tei:persName/(@key | @sameAS)) || $l"
            />
        </xsl:result-document>

        <!-- corpus-overview-extended.txt -->
        
        <xsl:result-document href="{$output-uri-2}" method="text">
            <xsl:value-of
                select="'Sender/innen' || $s || count(distinct-values($documents//tei:correspAction[@type = 'sent']/tei:persName/@key)) || $l"/>
            <xsl:value-of
                select="'Empfänger/innen' || $s || count(distinct-values($documents//tei:correspAction[@type = 'received']/tei:persName/@key)) || $l"/>
            <xsl:value-of
                select="'Ältester Brief' || $s || $min-date || $s || $documents[//tei:correspAction[@type = 'sent']/tei:date/(@when | @from)/xs:date(.) = $min-date]//tei:title[1]/normalize-space() || $l"/>
            <xsl:value-of
                select="'Jüngster Brief' || $s || $max-date || $s || $documents[//tei:correspAction[@type = 'sent']/tei:date/(@when | @to | @notAfter)/xs:date(.) = $max-date]//tei:title[1]/normalize-space() || $l"/>
            <xsl:value-of
                select="'Längster Brief (in Zeichen)' || $s || $max-length || $s || $documents[//tei:text/string-length() = $max-length]//tei:title[1]/normalize-space() || $l"/>
            <xsl:value-of
                select="'Kürzester Brief (in Zeichen)' || $s || $min-length || $s || $documents[//tei:text/string-length() = $min-length]//tei:title[1]/normalize-space() || $l"/>
            <xsl:value-of
                select="'Durchschnittliche Brieflänge (in Zeichen)' || $s || round(sum(//$documents/string-length(//tei:text)) div count($documents//tei:TEI)) || $l"/>
            <xsl:value-of
                select="'Indizierte Personen' || $s || count(distinct-values($documents//tei:text//tei:persName/@key)) || $l"/>
            <xsl:value-of
                select="'Indizierte Orte' || $s || count(distinct-values($documents//tei:text//tei:placeName/@key)) || $l"/>
            <xsl:value-of
                select="'Indizierte Werke' || $s || count(distinct-values($documents//tei:text//tei:bibl/@sameAs)) || $l"/>
            <xsl:value-of
                select="'Indizierungen Jean Pauls' || $s || count(distinct-values($documents//tei:text//tei:persName[@key = 'JP-999999'])) || $l"
            />
        </xsl:result-document>
        
    </xsl:template>

</xsl:stylesheet>
