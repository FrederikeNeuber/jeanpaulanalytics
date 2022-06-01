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
                select="replace($basename, 'data-source/umfeldbriefe/.*/', 'data-analysis/metadata/')"/>
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

    <!-- teiHeader: sections/attributes to delete -->

    <xsl:template match="@telota:doctype"/>

    <xsl:template match="tei:TEI/@type"/>

    <xsl:template match="tei:fileDesc//tei:respStmt"/>

    <xsl:template match="tei:fileDesc//tei:editionStmt"/>

    <xsl:template
        match="tei:correspDesc//@cert | tei:correspDesc/tei:note | tei:correspDesc/tei:correspContext"/>

    <!-- teiHeader: sections to modify -->

    <xsl:template match="tei:publicationStmt">
        <publicationStmt xmlns="http://www.tei-c.org/ns/1.0">
            <publisher ref="https://orcid.org/0000-0001-8279-9298">Frederike Neuber</publisher>
            <date when="2022-06"/>
            <availability>
                <licence target="http://creativecommons.org/licenses/by-sa/4.0/"/>
            </availability>
        </publicationStmt>
    </xsl:template>

    <xsl:template match="tei:sourceDesc">
        <sourceDesc xmlns="http://www.tei-c.org/ns/1.0">
            <p>The data set is derived from https://github.com/telota/jean_paul_briefe/tree/v.5.0,
                the XML data of https://www.jeanpaul-edition.de.</p>
        </sourceDesc>
    </xsl:template>

    <!-- teiHeader: sections to clean up -->

    <xsl:template match="tei:correspDesc//tei:persName[@key = 'JP-004373']">
        <persName xmlns="http://www.tei-c.org/ns/1.0" key="JP-004373">Unbekannte
            Korrespondent/innen</persName>
    </xsl:template>

    <xsl:template match="tei:correspDesc//tei:persName[@key = 'JP-999999']">
        <persName xmlns="http://www.tei-c.org/ns/1.0" key="JP-999999">Jean Paul</persName>
    </xsl:template>

    <xsl:template match="tei:keywords[@scheme = '#topics']">
        <xsl:variable name="topics" select="doc('../../data-source/register/Themen.xml')"/>
        <keywords xmlns="http://www.tei-c.org/ns/1.0" scheme="#topics">
            <xsl:for-each
                select="$topics//tei:body/tei:list/tei:item[.//@xml:id = current()/tei:term/substring-after(@corresp, '#')]">
                <term xml:id="{@xml:id}">
                    <xsl:value-of select="tei:label[@type = 'reg']/normalize-space()"/>
                </term>
            </xsl:for-each>
        </keywords>
    </xsl:template>

    <xsl:template match="tei:keywords[@scheme = '#correspondents']/tei:term">
        <term xmlns="http://www.tei-c.org/ns/1.0"
            xml:id="{current()/substring-after(@corresp, '#')}">
            <xsl:value-of select="normalize-space()"/>
        </term>
    </xsl:template>

    <!-- text: extract mentioned entities in lists -->

    <xsl:template match="tei:text">
        <text xmlns="http://www.tei-c.org/ns/1.0">
            <body>
                <xsl:if test="//tei:persName">
                    <listPerson>
                        <xsl:for-each-group select="//tei:persName" group-by="@key">
                            <person xml:id="{current-grouping-key()}" n="{count(current-group())}"/>
                        </xsl:for-each-group>
                    </listPerson>
                </xsl:if>
                <xsl:if test="//tei:placeName">
                <listPlace>
                    <xsl:for-each-group select="//tei:placeName" group-by="@key">
                        <place xml:id="{current-grouping-key()}" n="{count(current-group())}"/>
                    </xsl:for-each-group>
                </listPlace>
                </xsl:if>
                <xsl:if test="//tei:bibl[@subtype = 'werk']">
                <listBibl type="all">
                    <xsl:for-each-group select="//tei:bibl[@subtype = 'werk']" group-by="@sameAs">
                        <bibl xml:id="{current-grouping-key()}" n="{count(current-group())}"/>
                    </xsl:for-each-group>
                </listBibl>
                </xsl:if>
                <xsl:if test="//tei:bibl[@subtype = 'werke-jp']">
                <listBibl type="jp">
                    <xsl:for-each-group select="//tei:bibl[@subtype = 'werke-jp']"
                        group-by="@sameAs">
                        <bibl xml:id="{current-grouping-key()}" n="{count(current-group())}"/>
                    </xsl:for-each-group>
                </listBibl>
                </xsl:if>
            </body>
        </text>
    </xsl:template>

</xsl:stylesheet>
