<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:telota="http://www.telota.de" exclude-result-prefixes="#all" version="2.0">

    <!-- 
    @author: Frederike Neuber
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
            select="'file:///' || $output-cleaned || 'years-performance-various.txt'" as="xs:string"/>
        <xsl:variable name="output-uri-csv-2"
            select="'file:///' || $output-cleaned || 'years-performance-index.txt'" as="xs:string"/>

        <!-- CSV notation variables -->
        <xsl:variable name="s" select="';'"/>
        <xsl:variable name="l" select="'&#10;'"/>
        
        <!-- Variables for queries -->
        
        <xsl:variable name="all-letters"
            select="count(//$documents//tei:TEI)"/>
        <xsl:variable name="all-length"
            select="sum(//$documents/string-length(//tei:text))"/>
        <xsl:variable name="all-correspondents"
            select="count(distinct-values($documents//tei:correspAction[@type = 'sent' or @type = 'received']//tei:persName/@key))"/>
        <xsl:variable name="all-readers"
            select="count($documents//tei:correspAction[@type = 'read']//tei:persName/@key)"/>
        <xsl:variable name="all-commentors"
            select="count($documents//tei:text//@hand[. != '#author'])"/>
        <xsl:variable name="all-mentions"
            select="count(distinct-values($documents//tei:text//tei:persName/@key))"/>
        <xsl:variable name="all-topics"
            select="count(distinct-values($documents//tei:keywords[@scheme = '#topics']/tei:term))"/>
       

        <!-- years-performance-various.txt -->
        
        <xsl:result-document href="{$output-uri-csv-1}" method="text">
            <xsl:value-of
                select="'Jahr' || $s || 'Briefe' || $s || 'Durchschnittliche Brieflänge' || $s || 'Korrespondent/innen' || $s || 'Personenerwähnungen' || $s ||                       'Produktwert' || $l"/>
            <xsl:for-each-group select="$documents//tei:TEI"
                group-by="//tei:correspAction[@type = 'sent']/tei:date/(@when | @notBefore | @from)[1]/substring(., 1, 4)">
                <xsl:variable name="avLength"
                    select="round(sum(current-group()/string-length(//tei:text)) div count(current-group()))"/>
                <xsl:variable name="correspondents"
                    select="count(distinct-values(current-group()//tei:correspAction[@type = 'sent' or @type = 'received']//tei:persName/@key))"/>
                <xsl:variable name="mentions"
                    select="count(current-group()//tei:text//tei:persName/@key)"/>               
                <xsl:value-of
                    select="current-grouping-key() || $s || count(current-group()) || $s || $avLength || $s || $correspondents || $s || $mentions || $s || $s || count(current-group()) * $avLength * $correspondents * $mentions || $l"
                />
            </xsl:for-each-group>
        </xsl:result-document>
        
        <!-- years-performance-index.txt -->
        
        <xsl:result-document href="{$output-uri-csv-2}" method="text">
            <xsl:value-of
                select="'Jahr' || $s || 'Briefe' || $s || 'Brieflänge' || $s || 'Korrespondent/innen' || $s || 'Mitleser/innen' || $s || 'Kommentator/innen' || $s || 'Personenerwähnungen' || $s || 'Themen' || $s || 'Digital Performance Index' ||  $l"/>
            <xsl:for-each-group select="$documents//tei:TEI"
                group-by="//tei:correspAction[@type = 'sent']/tei:date/(@when | @notBefore | @from)[1]/substring(., 1, 4)">
                <xsl:variable name="index-letters"
                    select="count(current-group()) div $all-letters *  100"/>
                <xsl:variable name="length"
                    select="sum(current-group()/string-length(//tei:text))"/>
                <xsl:variable name="index-length"
                    select="$length div $all-length * 100"/>
                <xsl:variable name="correspondents"
                    select="count(distinct-values(current-group()//tei:correspAction[@type = 'sent' or @type = 'received']//tei:persName/@key))"/>
                <xsl:variable name="index-correspondents" select="$correspondents div $all-correspondents *  100"/>
                <xsl:variable name="readers"
                    select="count(current-group()//tei:correspAction[@type = 'read']//tei:persName/@key)"/>
                <xsl:variable name="index-readers" select="$readers div $all-readers *  100"/>
                <xsl:variable name="commentors"
                    select="count(current-group()//tei:text//@hand[. != '#author'])"/>
                <xsl:variable name="index-commentors" select="$commentors div $all-commentors *  100"/>
                <xsl:variable name="mentions"
                    select="count(distinct-values(current-group()//tei:text//tei:persName/@key))"/>
                <xsl:variable name="index-mentions" select="$mentions div $all-mentions *  100"/>
                <xsl:variable name="topics" select="count(distinct-values(current-group()//tei:keywords[@scheme = '#topics']/tei:term/@xml:id))"/>
                <xsl:variable name="index-topics" select="$topics div $all-topics *  100"/>
                
                <xsl:variable name="sum" select="$index-letters + $index-length + $index-correspondents + $index-readers + $index-commentors + $index-mentions + $index-topics"/>
                <xsl:value-of
                    
                    select="current-grouping-key() || $s || $index-letters || $s || $index-length || $s || $index-correspondents || $s || $index-readers || $s || $index-commentors || $s || $index-mentions || $s || $index-topics || $s || $sum div 7 || $l"
                />
            </xsl:for-each-group>
        </xsl:result-document>
        <!--  || $s || $index-commentors || $index-mentions || $s || $index-topics || $s || $product|| -->




    </xsl:template>

</xsl:stylesheet>
