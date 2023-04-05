<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:telota="http://www.telota.de" exclude-result-prefixes="#all" version="2.0">
    <xsl:param name="INPUT_DIR"/>
   
    <!-- 
    @author: Frederike Neuber
    --> 
    


    <xsl:template match="/">
        
        <!-- Paths for input/output data -->
        
       <xsl:variable name="input-cleaned" select="replace($INPUT_DIR, '\\', '/')" as="xs:string"/>
       <xsl:variable name="output-cleaned"
            select="replace($input-cleaned, 'data-preprocessed/letters-xml', 'results/')"
            as="xs:string"/>
        <xsl:variable name="input-dir-uri"
            select="'file:///' || $input-cleaned || '?recurse=yes;select=*.xml'" as="xs:string"/>
        <xsl:variable name="documents" select="collection($input-dir-uri)" as="document-node()*"/>
        
        <xsl:variable name="output-uri-csv-1" select="'file:///' || $output-cleaned || 'topics.txt'"
            as="xs:string"/>
        <xsl:variable name="output-uri-csv-2"
            select="'file:///' || $output-cleaned || 'topics-matrix.txt'" as="xs:string"/>
        <xsl:variable name="output-uri-csv-3"
            select="'file:///' || $output-cleaned || 'topics-year.txt'" as="xs:string"/>

        <!-- CSV variables -->

        <xsl:variable name="s" select="';'"/>
        <xsl:variable name="l" select="'&#10;'"/>      
        
        <!-- topics.txt -->
        
        <xsl:result-document href="{$output-uri-csv-1}" method="text">
            <xsl:value-of select="'Thema' || $s || 'Anzahl' || $l"/>
            <xsl:for-each-group select="$documents//tei:TEI//tei:keywords[@scheme = '#topics']"
                group-by="tei:term">
                <xsl:variable name="social-share" select="count(current-group()) div count($documents//tei:TEI//tei:keywords[@scheme = '#topics']/tei:term) * 100"/>
                    <xsl:variable name="topic" select="current-grouping-key()"/>
                    <xsl:value-of select="current-grouping-key() || $s || $social-share ||  $l"
                        />
            </xsl:for-each-group>
        </xsl:result-document>

        <!-- topics-matrix.txt -->
        <xsl:result-document href="{$output-uri-csv-2}" method="text">
              
            <xsl:for-each-group select="$documents//tei:TEI" group-by="//tei:keywords[@scheme = '#topics']/tei:term">
                 
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
        
        <!--<xsl:result-document href="{$output-uri-csv-2}" method="text">
            <xsl:variable name="name"
                select="'1800,1801,1802,1803,1804,1805,1806,1807,1808,1809,1810,1811,1812,1813,1814,1815,1816,1817,1818,1819,1820,1821,1822,1823,1824,1825,1826'"/>
            <xsl:value-of select="'Thema'"/>
            <xsl:for-each select="tokenize($name, ',')">
                <xsl:value-of select="$s || ."/>
            </xsl:for-each>
            <xsl:for-each-group select="$documents//tei:TEI"
                group-by="//tei:keywords[@scheme = '#topics']/tei:term">
                <xsl:sort select="count(current-group())" data-type="number" order="descending"/>
                <!-\-                <xsl:if test="count(current-group()) gt 100">-\->
                <xsl:value-of select="$l || current-grouping-key()"/>
                
                <xsl:for-each select="tokenize($name, ',')">
                    <xsl:value-of
                        select="$s || count(current-group()//tei:correspAction[@type = 'sent'][tei:date/(@when | @notBefore | @from)[1]/substring(., 1, 4) = current()])"
                    />
                </xsl:for-each>
                <!-\-                </xsl:if>-\->
            </xsl:for-each-group>
            <xsl:value-of select="$l"/>
        </xsl:result-document>-->
        
      <!--  <xsl:result-document href="{$output-uri-csv-2}" method="text">
            <xsl:variable name="name"
                select="'1800,1801,1802,1803,1804,1805,1806,1807,1808,1809,1810,1811,1812,1813,1814,1815,1816,1817,1818,1819,1820,1821,1822,1823,1824,1825,1826'"/>
            <xsl:value-of select="'Thema'"/>
            <xsl:for-each select="tokenize($name, ',')">
                <xsl:value-of select="$s || ."/>
            </xsl:for-each>
            <xsl:for-each-group select="$documents//tei:TEI"
                group-by="//tei:keywords[@scheme = '#topics']/tei:term">
                <xsl:sort select="count(current-group())" data-type="number" order="descending"/>
<!-\-                <xsl:if test="count(current-group()) gt 100">-\->
                <xsl:value-of select="$l || current-grouping-key()"/>
               
                <xsl:for-each select="tokenize($name, ',')">
                    <xsl:value-of
                        select="$s || count(current-group()//tei:correspAction[@type = 'sent'][tei:date/(@when | @notBefore | @from)[1]/substring(., 1, 4) = current()])"
                    />
                </xsl:for-each>
<!-\-                </xsl:if>-\->
            </xsl:for-each-group>
            <xsl:value-of select="$l"/>
        </xsl:result-document>-->
        
        
        
        <!-- currently not used // topics-year.txt -->
        
        <xsl:result-document href="{$output-uri-csv-3}" method="text">
            <xsl:value-of select="'Jahr' || $s || 'Thema' || $s || 'Anzahl' || $l"/>
            <xsl:for-each-group select="$documents//tei:TEI//tei:keywords[@scheme = '#topics']"
                group-by="tei:term">
                <xsl:variable name="topic" select="current-grouping-key()"/>
                <xsl:for-each-group select="current-group()"
                    group-by="preceding::tei:correspAction[@type = 'sent']/tei:date/(@when | @notBefore | @from)[1]/substring(., 1, 4)">
                    <xsl:value-of
                        select="current-grouping-key() || $s || $topic || $s || count(current-group()) || $l"
                    />
                </xsl:for-each-group>
            </xsl:for-each-group>
        </xsl:result-document>

    </xsl:template>
    
</xsl:stylesheet>
