<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:telota="http://www.telota.de" exclude-result-prefixes="#all" version="2.0">

    <!-- 
    @author: Frederike Neuber
    Creates a list of all correspondents and the number of the letters they sent, received and read.
    Output as CSV/TXT and XML.
    -->

    <!-- Input directory as defined in correspondents-roles.bat -->
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
            select="'file:///' || $output-cleaned || 'correspondents-influencer.txt'" as="xs:string"/>
        <xsl:variable name="output-uri-csv-2"
            select="'file:///' || $output-cleaned || 'correspondents-message-coverage.txt'"
            as="xs:string"/>
        <xsl:variable name="output-uri-csv-3"
            select="'file:///' || $output-cleaned || 'correspondents-year.txt'" as="xs:string"/>
        <xsl:variable name="output-uri-csv-4"
            select="'file:///' || $output-cleaned || 'correspondents-roles.txt'" as="xs:string"/>

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
        
        <xsl:result-document href="{$output-uri-csv-1}" method="text">
            <xsl:value-of
                select="'Person' || $s || 'Korrespondenz' || $s || 'Kommentierung' || $s || 'Lesen' || $s || 'Kreise' || $s || 'Themen' || $s || 'Score' ||  $l"/>
            <xsl:for-each-group select="$documents//tei:correspAction//tei:persName" group-by="@key">
                <xsl:sort select="count(current-group())" data-type="number" order="descending"/>
                <xsl:variable name="comments" select="count($documents[//tei:correspAction[@type = 'sent']/tei:persName/@key[. != current-grouping-key()]]//tei:text//@hand[. = concat('#', current-grouping-key())])"/>
                <xsl:variable name="circle" select="count(distinct-values($documents[//tei:correspAction[@type = 'sent']/tei:persName/@key[. = current-grouping-key()]]//tei:keywords[@scheme='#correspondents']/tei:term))"/>
                <xsl:variable name="topics" select="count(distinct-values($documents[//tei:correspAction[@type = 'sent']/tei:persName/@key[. = current-grouping-key()]]//tei:keywords[@scheme='#topics']/tei:term))"/>
                <xsl:variable name="av-correspondents" select="count(current-group()/parent::tei:correspAction[@type = 'sent' or @type = 'received']) div $all-correspondents * 100"/>
                <xsl:variable name="av-readers" select="count(current-group()/parent::tei:correspAction[@type = 'read']) div $all-readers * 100"/>
                <xsl:variable name="av-commentors" select="$comments div $all-commentors * 100"/>
                <xsl:variable name="av-topics" select="$topics div $single-topics * 100"/>
                <xsl:variable name="av-circle" select="$circle div $single-circle * 100"/>
                <xsl:variable name="score" select=" $av-correspondents + $av-commentors + $av-readers + $av-topics + $av-circle"/>
                
                <xsl:value-of select=". || $s || format-number($av-correspondents, '#.###') || $s || format-number($av-commentors, '#.###')|| $s || format-number($av-readers, '#.###') || $s || format-number($av-topics, '#.###') || $s || format-number($av-circle, '#.###')  || $s || format-number($score div 5, '#.###') ||  $l"/>
       
            </xsl:for-each-group>
        </xsl:result-document>
        
        

        <!-- correspondents-message-coverage.txt -->
        
        <xsl:result-document href="{$output-uri-csv-2}" method="text">
            <xsl:value-of
                select="'Korrespondent/innen' || $s || 'Bruttoreichweite (Summe aller Personenkontakte)' || $s || 'Nettoreichweite (Erreichte Personen)' || $s || 'Durchschnittliche Kontaktchance (OTS)' || $l"/>
            <xsl:for-each-group select="$documents//tei:correspAction[@type = 'sent']/tei:persName"
                group-by="@key">
                <xsl:sort select="count(current-group())" data-type="number" order="descending"/>
                <xsl:variable name="person" select="distinct-values(current-group())"/>
                <xsl:variable name="brw"
                    select="count(current-group()/following::tei:correspAction[@type = 'received' or @type = 'read']/tei:persName/@key)"/>
                <xsl:variable name="nrw"
                    select="count(distinct-values(current-group()/following::tei:correspAction[@type = 'received' or @type = 'read']/tei:persName/@key))"/>
                <xsl:variable name="drw" select="number($brw div $nrw)"/>
                <xsl:value-of select="$person || $s || $brw || $s || $nrw || $s || $drw || $l"/>
            </xsl:for-each-group>
        </xsl:result-document>
        
        <!-- currently not used /// correspondents-years.txt -->
        
        <xsl:result-document href="{$output-uri-csv-3}" method="text">
            <xsl:value-of
                select="'Jahr' || $s || 'Korrespondent/in' || $s || 'Gesendet' || $s || 'Empfangen' || $s || 'Gelesen' || $s ||  'Alle Briefe' || $l"/>
            <xsl:for-each-group select="$documents//tei:correspAction/tei:persName" group-by="@key">
                <xsl:sort select="count(current-group())" data-type="number" order="descending"/>
                <xsl:variable name="key" select="current-grouping-key()"/>
                <xsl:for-each-group select="current-group()"
                    group-by="ancestor::tei:correspDesc/tei:correspAction[1]/tei:date/(@when | @notBefore | @from)[1]/substring(., 1, 4)">
                    <xsl:value-of select="current-grouping-key() || $s || . || $s"/>
                    <xsl:value-of
                        select="count(current-group()/parent::tei:correspAction[@type = 'sent']) || $s"/>
                    <xsl:value-of
                        select="count(current-group()/parent::tei:correspAction[@type = 'received']) || $s"/>
                    <xsl:value-of
                        select="count(current-group()/parent::tei:correspAction[@type = 'read']) || $s"/>
                    <xsl:value-of select="count(current-group()) || $l"/>
                </xsl:for-each-group>
            </xsl:for-each-group>
        </xsl:result-document>
        
        <xsl:result-document href="{$output-uri-csv-4}" method="text">
            <xsl:value-of
                select="'Korrespondent/in' || $s || 'Gesendet' || $s || 'Empfangen' || $s || 'Gelesen' || $s || 'Kommentiert' || $s || 'Gesendet/Gelesen/Kommentiert' || $s || 'alle Interaktionen' || $l"/>
            <xsl:for-each-group select="$documents//tei:correspAction//tei:persName" group-by="@key">
                <xsl:sort select="count(current-group())" data-type="number" order="descending"/>
                <xsl:variable name="comments" select="count($documents[//tei:correspAction[@type = 'sent']/tei:persName/@key[. != current-grouping-key()]]//tei:text//@hand[. = concat('#', current-grouping-key())])"/>
                <xsl:value-of select=". || $s"/>
                <xsl:value-of
                    select="count(current-group()/parent::tei:correspAction[@type = 'sent']) || $s"/>
                <xsl:value-of
                    select="count(current-group()/parent::tei:correspAction[@type = 'received']) || $s"/>
                <xsl:value-of
                    select="count(current-group()/parent::tei:correspAction[@type = 'read']) || $s"/>
                <xsl:value-of
                    select="$comments || $s"/>
                <xsl:value-of select="count(current-group()/parent::tei:correspAction[@type = 'sent']) + count(current-group()/parent::tei:correspAction[@type = 'read']) + $comments || $s"/>
                <xsl:value-of select="count(current-group())+ $comments || $l"/>
            </xsl:for-each-group>
        </xsl:result-document>

    </xsl:template>

</xsl:stylesheet>
