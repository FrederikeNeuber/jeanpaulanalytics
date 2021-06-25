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
        <xsl:variable name="output-cleaned" select="replace($input-cleaned, 'data-preprocessed/letters-ling', 'results/')" as="xs:string"/>
        
        <!-- Defines input XML collection -->
        <xsl:variable name="input-dir-uri" select="'file:///' || $input-cleaned || '?recurse=yes;select=*.xml'" as="xs:string"/>
        <xsl:variable name="documents" select="collection($input-dir-uri)" as="document-node()*" />
        
        <!-- Defines output file --> 
        <xsl:variable name="output-uri-csv" select="'file:///' || $output-cleaned || 'sentiment-adjectives.txt'" as="xs:string"/>
        
        <!-- CSV notation variables -->
        <xsl:variable name="s" select="';'"/>
        <xsl:variable name="l" select="'&#10;'"/>
        
        <!-- Result as TXT/CSV -->    
        <xsl:result-document href="{$output-uri-csv}" method="text">
            <xsl:value-of select="'Adjektiv' || $s || 'Anzahl' || $l"/>
            <xsl:for-each-group select="$documents//tei:TEI//tei:moot[@tag='ADJA']" group-by="@lemma">
                <xsl:sort select="count(current-group())" data-type="number" order="descending"/>
                <xsl:value-of select="current-grouping-key() || $s || count(current-group()) || $l"/>         
            </xsl:for-each-group>
        </xsl:result-document>
     <!--   
        <xsl:result-document href="{$output-uri-csv}" method="text">
            <xsl:value-of select="'Jahr' || $s || 'Korrespondent/innen' || $s || 'Gesendet' || $s || 'Empfangen' || $s  || 'Gelesen' || $s || 'Alle Briefe' || $l"/>
            <xsl:for-each-group select="$documents//tei:correspAction/tei:persName" group-by="@key">
                <xsl:sort select="count(current-group())" data-type="number" order="descending"></xsl:sort>                
                <xsl:for-each-group select="current-group()" group-by="ancestor::tei:correspDesc/tei:correspAction[1]/tei:date/(@when | @notBefore | @from)[1]/substring(., 1, 4)">
                <xsl:value-of select="current-grouping-key() || $s || . || $s"/>
                <xsl:value-of select="count(current-group()/parent::tei:correspAction[@type='sent']) || $s"/>
                <xsl:value-of select="count(current-group()/parent::tei:correspAction[@type='received']) || $s"/>
                <xsl:value-of select="count(current-group()/parent::tei:correspAction[@type='read']) || $s"/>
                <xsl:value-of select="count(current-group()) || $l"/>
                </xsl:for-each-group>
            </xsl:for-each-group>
        </xsl:result-document>-->
        
    </xsl:template>
    
</xsl:stylesheet>