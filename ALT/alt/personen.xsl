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
            select="replace($input-cleaned, 'data-analysis/metadata', 'results/')"
            as="xs:string"/>
        
        <!-- Defines input XML collection -->
        <xsl:variable name="input-dir-uri"
            select="'file:///' || $input-cleaned || '?recurse=yes;select=*.xml'" as="xs:string"/>
        <xsl:variable name="documents" select="collection($input-dir-uri)" as="document-node()*"/>
        
        <!-- Defines output file -->
        <xsl:variable name="output-uri-csv-1"
            select="'file:///' || $output-cleaned || 'personen-uebersicht.txt'" as="xs:string"/>
        <xsl:variable name="output-uri-csv-2"
            select="'file:///' || $output-cleaned || 'personen-reichweite.txt'" as="xs:string"/>
        <xsl:variable name="output-uri-csv-3"
            select="'file:///' || $output-cleaned || 'topics-years.txt'" as="xs:string"/>
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
        
    <!--    <xsl:variable name="all-letters"
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
            select="count(distinct-values($documents//tei:keywords[@scheme = '#correspondents']/tei:term))"/>-->
        
        <!-- übersicht.txt -->
        
        <xsl:result-document href="{$output-uri-csv-1}" method="text">
            <xsl:value-of select="'Alle Briefe' || $s || count($documents//tei:TEI) || $l"/>
            <xsl:value-of
                select="'Alle Korrespondent/innen' || $s || count(distinct-values($documents//tei:correspAction/tei:persName/@key)) || $l"/>
            <xsl:value-of
                select="'Sender/innen' || $s || count(distinct-values($documents//tei:correspAction[@type = 'sent']/tei:persName/@key)) || $l"/>
            <xsl:value-of
                select="'Summe aller Sendekontakte' || $s || count($documents//tei:correspAction[@type = 'sent']/tei:persName) || $l"/>
            <xsl:value-of
                select="'Empfänger/innen' || $s || count(distinct-values($documents//tei:correspAction[@type = 'received' or @type = 'read']/tei:persName/@key)) || $l"/>
            <xsl:value-of
                select="'Mitleser/innen' || $s || count(distinct-values($documents//tei:correspAction[@type = 'read']/tei:persName/@key)) || $l"/>
            <xsl:value-of
                select="'Summe aller Empfangskontakte' || $s || count($documents//tei:correspAction[@type = 'received' or @type='read']/tei:persName) || $l"/>
           </xsl:result-document>
        
         <!-- reichweite.txt -->
        
        <xsl:result-document href="{$output-uri-csv-2}" method="text">
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
        
        <!-- topics-years.txt -->
        <xsl:result-document href="{$output-uri-csv-3}" method="text">
            <xsl:text>Thema;Insgesamt;1800;1801;1802;1803;1804;1805;1806;1807;1808;1809;1810;1811;1812;1813;1814;1815;1816;1817;1818;1819;1820;1821;1822;1823;1824;1825;1826</xsl:text>
            <xsl:for-each-group select="$documents//tei:TEI[//tei:correspAction[@type = 'sent']/tei:date/(@when | @notBefore | @from)]" group-by="//tei:keywords[@scheme = '#topics']/tei:term">
                
                <xsl:sort select="count(current-group())" data-type="number" order="descending"/>
                <xsl:variable name="name"
                    select="'1800,1801,1802,1803,1804,1805,1806,1807,1808,1809,1810,1811,1812,1813,1814,1815,1816,1817,1818,1819,1820,1821,1822,1823,1824,1825,1826'"/>
                
                <xsl:value-of select="$l || current-grouping-key()"/>
                <xsl:value-of select="$s || count(current-group())"/>
                <xsl:for-each select="tokenize($name, ',')">
                    <xsl:value-of
                        select="$s || count(current-group()//tei:correspAction[@type = 'sent'][tei:date/(@when | @notBefore | @from)[1]/substring(., 1, 4) = current()])"
                    />
                </xsl:for-each>
              
            </xsl:for-each-group>
            <xsl:value-of select="$l"/>
        </xsl:result-document>
        
      
        
    </xsl:template>
    
</xsl:stylesheet>
