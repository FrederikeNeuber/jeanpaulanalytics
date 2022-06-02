<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:telota="http://www.telota.de" exclude-result-prefixes="#all" version="2.0">
    <xsl:param name="INPUT_DIR"/>

    <xsl:strip-space elements="*"/>

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
        <xsl:variable name="input-dir-uri"
            select="'file:///' || replace($INPUT_DIR, '\\', '/') || '?recurse=yes;select=*.xml'"
            as="xs:string"/>
        <xsl:variable name="documents" as="document-node()*" select="collection($input-dir-uri)"/>

        <xsl:for-each select="$documents">
            <xsl:variable name="cur-doc" select="." as="document-node()"/>
            <xsl:variable name="basename" as="xs:string" select="string(base-uri($cur-doc))"/>
            <xsl:variable name="output-uri"
                select="replace($basename, 'data-source/umfeldbriefe/.*/', 'data-preprocessed/letters-xml/')"/>
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

    <!-- teiHeader: attributes/sections to delete -->

    <xsl:template match="@telota:doctype"/>

    <xsl:template match="tei:TEI/@type"/>

    <xsl:template match="tei:fileDesc//tei:respStmt"/>

    <xsl:template match="tei:fileDesc//tei:editionStmt"/>
    
    <xsl:template match="tei:correspDesc//tei:persName[@key = 'JP-004373']">
        <persName xmlns="http://www.tei-c.org/ns/1.0" key="JP-004373">Unbekannte Korrespondent/innen</persName>
    </xsl:template>
    
    <xsl:template match="tei:correspDesc//tei:persName[@key = 'JP-999999']">
        <persName xmlns="http://www.tei-c.org/ns/1.0" key="JP-999999">Jean Paul</persName>
    </xsl:template>
    

    <xsl:template match="tei:correspDesc/tei:note | tei:correspDesc/tei:correspContext"/>

    <!-- teiHeader: sections to modify -->

    <xsl:template match="tei:publicationStmt">
        <publicationStmt xmlns="http://www.tei-c.org/ns/1.0">
            <publisher ref="https://orcid.org/0000-0001-8279-9298">Frederike Neuber</publisher>
            <date when="2021-06"/>
            <availability>
                <licence target="http://creativecommons.org/licenses/by-sa/4.0/"/>
            </availability>
        </publicationStmt>
    </xsl:template>

    <xsl:template match="tei:sourceDesc">
        <sourceDesc xmlns="http://www.tei-c.org/ns/1.0">
            <p>The data set is derived from https://github.com/telota/jean_paul_briefe/tree/v.4.0,
                the XML data of https://www.jeanpaul-edition.de.</p>
        </sourceDesc>
    </xsl:template>

    <xsl:template match="tei:keywords[@scheme = '#topics']/tei:term">
        <xsl:variable name="topics" select="doc('../../data-source/register/Themen.xml')"/>
        <xsl:choose>
            <xsl:when
                test="$topics//tei:body/tei:list/tei:item[@xml:id = current()/substring-after(@corresp, '#')]">
                <term  xmlns="http://www.tei-c.org/ns/1.0" xml:id="{current()/substring-after(@corresp, '#')}">
                    <xsl:value-of
                        select="$topics//tei:body/tei:list/tei:item[@xml:id = current()/substring-after(@corresp, '#')]/tei:label/normalize-space()"
                    />
                </term>
            </xsl:when>
            <xsl:otherwise>
                <term xmlns="http://www.tei-c.org/ns/1.0" xml:id="{$topics//tei:item[tei:list/tei:item[@xml:id=current()/substring-after(@corresp, '#')]]/@xml:id}">
                        <xsl:value-of
                            select="$topics//tei:item[tei:list/tei:item[@xml:id=current()/substring-after(@corresp, '#')]]/tei:label/normalize-space()"
                        />
                    </term>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    


    <xsl:template match="tei:keywords[@scheme = '#correspondents']/tei:term">
        <term  xmlns="http://www.tei-c.org/ns/1.0" xml:id="{current()/substring-after(@corresp, '#')}">
            <xsl:value-of select="normalize-space()"/>
        </term>  
    </xsl:template>
    <!-- text: normalizations -->

    <!-- muss raus!!! -->
    <xsl:template match="tei:bibl/@key">
        <xsl:attribute name="sameAs">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="tei:seg[not(@type = 'comment')]">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:seg[@type = 'comment']">
        <xsl:apply-templates select="tei:orig"/>
    </xsl:template>

    <xsl:template match="tei:subst">
        <xsl:apply-templates select="tei:add"/>
    </xsl:template>

    <xsl:template match="tei:choice[tei:sic | tei:orig]">
        <xsl:apply-templates select="tei:sic | tei:orig"/>
    </xsl:template>

    <xsl:template match="tei:hi | tei:orig | tei:add | tei:unclear | tei:sic | tei:supplied | tei:ex">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:del | tei:corr | tei:reg | tei:gap"/>

    <!-- text: other clean ups -->

    <xsl:template match="tei:hi[not(@hand)] | tei:text//tei:date | tei:foreign">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:div/@type | tei:div/@xml:id | @cert"/>

    <xsl:template match="tei:lb | tei:pb | tei:space">
        <xsl:value-of select="' '"/>
    </xsl:template>

</xsl:stylesheet>
