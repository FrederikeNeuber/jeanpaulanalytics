<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:telota="http://www.telota.de" exclude-result-prefixes="#all" version="2.0">
    <xsl:param name="INPUT_DIR"/>

    <xsl:template match="/">

        <xsl:variable name="input-cleaned" select="replace($INPUT_DIR, '\\', '/')" as="xs:string"/>
        <xsl:variable name="output-cleaned"
            select="replace($input-cleaned, 'data-preprocessed/letters-xml', 'data-preprocessed/')"
            as="xs:string"/>

        <xsl:variable name="input-dir-uri"
            select="'file:///' || $input-cleaned || '?recurse=yes;select=*.xml'" as="xs:string"/>

        <xsl:variable name="output-uri" select="'file:///' || $output-cleaned"/>

        <xsl:variable name="documents" as="document-node()*" select="collection($input-dir-uri)"/>

        <xsl:for-each select="$documents">
            <xsl:variable name="cur-doc" select="." as="document-node()"/>
            <xsl:variable name="basename" as="xs:string" select="string(base-uri($cur-doc))"/>
            <xsl:variable name="output-uri"
                select="replace($basename, 'letters-xml/(.+?)\.xml', 'letters-plain/$1.txt')"/>
            <xsl:result-document href="{$output-uri}" method="text" indent="no" media-type="text">
                <xsl:apply-templates select="//@word"/>
            </xsl:result-document>
        </xsl:for-each>

        <!-- for sentiment analysis; group by correspondent -->
        <xsl:for-each-group select="$documents//tei:TEI"
            group-by="//tei:correspAction[@type = 'sent']/tei:persName/@key">
            <xsl:variable name="filename" select="current-grouping-key()"/>
            <xsl:variable name="name"
                select="distinct-values(current-group()//tei:correspAction[@type = 'sent']/tei:persName[@key = current-grouping-key()])"/>
            <xsl:result-document
                href="{$output-uri || 'letters-plain-sentiment/correspondents/' ||  replace($name, ' ', '-') || '_' || $filename  || '.txt'}"
                method="text" indent="no" media-type="text">
                <xsl:apply-templates select="current-group()//@word"/>
            </xsl:result-document>
        </xsl:for-each-group>

        <!-- for sentiment analysis; group by year -->

        <xsl:for-each-group select="$documents//tei:TEI"
            group-by="//tei:correspAction[@type = 'sent']/tei:date/(@when | @notBefore | @from)[1]/substring(., 1, 4)">
            <xsl:variable name="filename" select="current-grouping-key()"/>
            <xsl:result-document
                href="{$output-uri || 'letters-plain-sentiment/years/' || $filename || '.txt'}"
                method="text" indent="no" media-type="text">
                <xsl:apply-templates select="current-group()//@word"/>
            </xsl:result-document>
        </xsl:for-each-group>

        <!-- for sentiment analysis; group by keyword  -->

        <xsl:for-each-group select="$documents//tei:TEI"
            group-by="//tei:keywords[@scheme = '#topics']/tei:term">
            <xsl:variable name="id" select="current-grouping-key()"/>
            <xsl:result-document
                href="{$output-uri || 'letters-plain-sentiment/keywords/' || replace(replace($id, ' ', '-'), '/', '-') || '.txt'}"
                method="text" indent="no" media-type="text">
                <xsl:apply-templates select="current-group()//@word"/>
            </xsl:result-document>
        </xsl:for-each-group>

        <!-- for sentiment analysis of specific keywords;  -->

        <xsl:for-each-group
            select="$documents//tei:TEI[//tei:keywords[@scheme = '#topics']/tei:term[@xml:id = 'JP-012601']]"
            group-by="//tei:correspAction[@type = 'sent']/tei:date/(@when | @notBefore | @from)[1]/substring(., 1, 4)">
            <xsl:variable name="id" select="current-grouping-key()"/>
            <xsl:result-document
                href="{$output-uri || 'letters-plain-sentiment/' || distinct-values(current-group()//tei:keywords[@scheme = '#topics']/tei:term[@xml:id='JP-012601']) || '/' || replace($id, ' ', '-') || '.txt'}"
                method="text" indent="no" media-type="text">
                <xsl:apply-templates select="current-group()//@word"/>
            </xsl:result-document>
        </xsl:for-each-group>

    </xsl:template>

    <xsl:template match="@word">
        <xsl:value-of select=". || ' '"/>
    </xsl:template>




</xsl:stylesheet>
