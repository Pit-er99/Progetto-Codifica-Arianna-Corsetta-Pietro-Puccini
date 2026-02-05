<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:tei="http://www.tei-c.org/ns/1.0"
xmlns="http://www.w3.org/1999/xhtml"
version="2.0">

<!-- Output HTML-->
<xsl:output method="html" encoding="UTF-8" indent="yes"/>

<!-- Template principale: creo la struttura html-->
<xsl:template match="/">
<html>
    <head>
        <title>
            <xsl:value-of select="//tei:titleStsmt/tei:title"/>
        </title>
        <meta charset="UTF-8"/>
        <link rel="stylesheet" href="stile.css"/>
        <script src="script.js"></script>
    </head>
    <body>
        <h1> 
            <xsl:value-of select="//tei:titleStmt/tei:title"/> 
        </h1>
        <section class="header-info">
            <h4>Progetto a cura di:</h4>
            <p>
                <xsl:for-each select="//tei:titleStmt/tei:respStmt[tei:persName/tei:forename='Arianna' or tei:persName/tei:forename='Pietro']">
                    <xsl:for-each select="tei:persName">
                        <xsl:value-of select="tei:forename"/>
                        <xsl:text> </xsl:text> <!-- Usato elemento text per creare una riga vuota di spazio-->
                        <xsl:value-of select="tei:surname"/>
                        <xsl:if test="position()!=last()">, </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
            </p>
            <p>
                <xsl:for-each select="//tei:notesStmt">
                    <xsl:value-of select="//tei:notesStmt/tei:note[@xml:id='title']"/>
                </xsl:for-each>
            </p>
        </section>
    <div class="info">
        <!-- Legenda-->
            <section class="legenda">
            <h2 class="titoloCliccabile">Legenda degli elementi evidenziati</h2>
            <div class="contenutoCliccabile1">
                <ul>
                    <li><span class="person-real">Nomi di persone reali</span></li>
                    <li><span class="person-fictional">Nomi di personaggi immaginari</span></li>
                    <li><span class="work">Titoli di opere</span></li>
                    <li><span class="place">Nomi di luoghi</span></li>
                    <li><span class="org">Casa editrice/Rivista/Organizzazione varia</span></li>
                    <li><span class="date">Date</span></li>
                    <li><span class="theme">Temi ricorrenti scelti</span></li>
                    <li><span class="movement">Correnti letterarie/artistiche</span></li>
                    <li><span class="foreign">Testo in lingua straniera</span></li>
                    <li><span class="quote">Citazioni</span></li>
                    <li><span class="epithet">Epiteti</span></li>
                </ul>
            </div>
            </section>

        <!-- Info sul progetto-->
        <section class="info-progetto">
            <h3 class="titoloCliccabile">
                Info sul progetto
            </h3>
            <div class="contenutoCliccabile1">
                <h4>Descrizione del progetto</h4>
                <p>
                    <xsl:value-of select="//tei:projectDesc/tei:p"/>
                </p>
                <h4>Criteri di selezione dei testi</h4>
                <xsl:for-each select="//tei:samplingDecl/tei:p">
                    <p>
                        <xsl:value-of select="."/>
                    </p>
                </xsl:for-each>
                <h4>Info su pratiche editoriali applicate durante la codifica</h4>
                <p>
                    <xsl:value-of select="//tei:hyphenation/tei:p"/>
                </p>
                <p>
                    <xsl:value-of select="//tei:normalization/tei:p"/>
                </p>
                <p>
                    <xsl:value-of select="//tei:quotation/tei:p"/>
                </p>
                <p>
                    <xsl:value-of select="//tei:interpretation/tei:p"/>
                </p>
            </div>
        </section>
    </div>
    
    <!-- TESTO-->
    <xsl:apply-templates select="//tei:body"/>
        
    <!-- Elenco dei nomi-->
    <section class="elencoNomi">
        <h2 class="titoloCliccabile">Indice dei nomi: </h2>
        <div class="contenutoCliccabile">
        <!-- il for-each-group prima raggruppa gli elementi e poi cicla una volta per gruppo-->
        <xsl:for-each-group select="//tei:persName" group-by="@type">
            <h3>
                <xsl:choose>
                    <xsl:when test="current-grouping-key() = 'real'">
                        Persone reali
                    </xsl:when>
                    <xsl:when test="current-grouping-key() = 'fictional'">
                        Personaggi immaginari
                    </xsl:when>
                    <xsl:when test="current-grouping-key() = 'mythological'">
                        Personaggi mitologici
                    </xsl:when>
                    <xsl:otherwise>
                        Non classificati
                    </xsl:otherwise>
                    </xsl:choose>
            </h3>
            <ul>
            <!-- faccio in modo che, nel caso di abbreviazioni, l'elemento da considerare sia solo l'expan-->
            <!-- ancestor mi indica, in questo caso, di evitare del contenuto che ha come elemento padre quello indicato dopo ancestor (es. ancestor::tei:choice mi dice di evitare del contenuto se questo ha come antenato il tag choice)-->
                <xsl:for-each-group 
                select="current-group()" 
                group-by="lower-case(normalize-space
                                    (string-join((
                                    .//tei:choice/tei:expan, 
                                    .//text()[normalize-space()]
                                    [not(ancestor::tei:choice)][not(ancestor::tei:abbr)][not(ancestor::tei:roleName)]), ' ')))">
                
                <!-- ordine alfabetico -->
                <xsl:sort select="current-grouping-key()" lang="it"/>
                <!-- ricompongo tutto in un elenco, in cui però mantengo le lettere maiuscole iniziali -->
                <li>
                    <xsl:variable name="nome" select="normalize-space(
                    string-join((
                                .//tei:choice/tei:expan, 
                                .//text()[normalize-space()]
                                [not(ancestor::tei:choice)][not(ancestor::tei:abbr)][not(ancestor::tei:roleName)]), ' '))"/>
                    <xsl:value-of select="$nome"/>
                </li>

            </xsl:for-each-group>
            </ul>
        </xsl:for-each-group>
        </div>
    </section>

    <!-- Elenco dei luoghi in base all'attributo type-->
    <section class="elencoNomi">
        <h2 class="titoloCliccabile">Indice dei luoghi: </h2>
        <div class="contenutoCliccabile">   
            <xsl:for-each-group select="//tei:placeName" group-by="if(@type) then @type else 'non-classificato'">
                <h3>
                    <xsl:choose>
                        <xsl:when test="current-grouping-key() = 'city'">
                            Città
                        </xsl:when>
                        <xsl:when test="current-grouping-key() = 'country'">
                            Stati
                        </xsl:when>
                        <xsl:when test="current-grouping-key() = 'region'">
                            Regioni (fisiche o politiche)
                        </xsl:when>
                        <xsl:when test="current-grouping-key() = 'continent'">
                            Continenti  
                        </xsl:when>
                        <xsl:when test="current-grouping-key() = 'natural'">
                            Luoghi naturali
                        </xsl:when>
                        <xsl:when test="current-grouping-key() = 'river'">
                            Fiumi       
                        </xsl:when>
                        <xsl:when test="current-grouping-key() = 'island'">
                            Isole
                        </xsl:when>
                        <xsl:when test="current-grouping-key() = 'sea'">
                            Mari e oceani
                        </xsl:when>
                        <xsl:when test="current-grouping-key() = 'mountain'">
                            Montagne
                        </xsl:when>
                        <xsl:when test="current-grouping-key() = 'monument'">
                            Monumenti   
                        </xsl:when>
                        <xsl:when test="current-grouping-key() = 'other'">
                            Altri luoghi
                        </xsl:when>
                    </xsl:choose>
                </h3>
                    <ul>
                        <!-- per ogni nome di luogo, evito che lo stesso luogo sia ripetuto anche se scritto in modo diverso (evito per es. roma, ROMA)-->
                        <xsl:for-each-group select="current-group()" group-by="lower-case(normalize-space(.))">
                        <!-- ordine alfabetico -->
                        <xsl:sort select="current-grouping-key()" lang="it"/>   
                            <li>
                                <xsl:value-of select="normalize-space(.)"/>
                            </li>
                        </xsl:for-each-group>
                    </ul>
                    
            </xsl:for-each-group>  
        </div>
    </section>
        
        <!-- Footer-->
        <footer>
            <hr/>
            <p>
                <strong>Titolo: </strong>
                <xsl:value-of select="//tei:titleStmt/tei:title"/>
            </p>
            <p>
                <strong>Autori: </strong>
                <xsl:for-each select="//tei:titleStmt/tei:author/tei:persName">
                    <xsl:value-of select="normalize-space(.)"/> 
                    <xsl:if test="position() != last()">,</xsl:if>
                </xsl:for-each>
            </p>
            <p>
                <strong>Responsabili:</strong>
                <xsl:for-each select="//tei:respStmt">
                    <br/>
                    <em><xsl:value-of select="tei:resp"/>: </em>
                    <xsl:for-each select="tei:persName|tei:orgName">
                        <!-- Uso normalize-space(.) per eliminare spazi extra-->
                        <xsl:value-of select="normalize-space(.)"/>
                        <!-- Se non si tratta dell'ultimo elemento stampo una virgola-->
                        <xsl:if test="position() !=last()">, </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
            </p>
            <p>
                <strong>Pubblicazione: </strong>
                <xsl:value-of select="//tei:publicationStmt/tei:publisher"/>,
                <xsl:value-of select="//tei:publicationStmt/tei:pubPlace"/>, 
                <xsl:value-of select="//tei:publicationStmt/tei:date"/>
            </p>
            <p>
                <strong>Note: </strong>
                <xsl:value-of select="//tei:notesStmt/tei:note[@xml:id='footer']"/>
            </p>
        </footer>

    </body>
</html>
</xsl:template>

    <!-- Body-->
<xsl:template match="tei:body">
    <xsl:apply-templates/>
</xsl:template>

<!--Visualizzo i titoli degli articoli, cliccabili-->
<xsl:template match="tei:div[@type='textArticle']">
    <div class="articoloCliccabile">
        <button class="titoloCliccabile">
            <xsl:apply-templates select="tei:head"/>
        </button>

        <!-- Imposto la pagina divisa in due colonne, una per le immagini del testo e l'altra per il testo trascritto-->
        <div class="contenutoCliccabile">
            <!-- colonna immagini-->
                <div class="colonna-immagini">
                <xsl:apply-templates select="tei:pb[@facs]"/>
                </div>
            
            <!-- colonna testo-->
                <div class="colonna-testo">
                <xsl:apply-templates select="tei:div/tei:p|tei:p"/>
                </div>
        </div>
    </div>
</xsl:template>

<!-- Template per il ritaglio rettangolare delle immagini -->
<xsl:template name="cut">
    <xsl:param name="imgUrl" as="xs:string"/>
    <xsl:param name="zone" as="element(tei:zone)"/>

    <xsl:variable name="ulx" select="xs:double($zone/@ulx)"/>
    <xsl:variable name="uly" select="xs:double($zone/@uly)"/>
    <xsl:variable name="lrx" select="xs:double($zone/@lrx)"/>
    <xsl:variable name="lry" select="xs:double($zone/@lry)"/>
    <xsl:variable name="w" select="$lrx - $ulx"/>
    <xsl:variable name="h" select="$lry - $uly"/>

    <div class="cut" style="width:{format-number($w,'0.##')}px; height:{format-number($h,'0.##')}px;">
        <img src="{$imgUrl}" alt=""
            style="left:-{format-number($ulx,'0.##')}px; top:-{format-number($uly,'0.##')}px;"/>
    </div>  
</xsl:template>


<!-- Template per le immagini: mostra solo i ritagli (zone) -->
<xsl:template match="tei:pb[@facs]">
    <!-- crea la variabile name con dentro la stringa di facs-->
    <xsl:variable name="imgUrl" select="string(@facs)" as="xs:string"/>

    <!-- una volta dato il nome alla variabile, cerco una surface (un ritaglio dell'immagine definito nell'xml) che corrisponda all'url-->
    <xsl:variable name="surface"
        select="//tei:facsimile/tei:surface[tei:graphic/@url = $imgUrl][1]"
        as="element(tei:surface)?"/>

    <!-- definisco un contenitore html che:-->
    <div class="screenshot img">
        <!-- verifica che ci sia una surface e che abbia le coordinate -->
        <xsl:if test="$surface and $surface/tei:zone[@ulx and @uly and @lrx and @lry]">
        <xsl:for-each select="$surface/tei:zone[@ulx and @uly and @lrx and @lry]">
            <!-- regola per il ritagli delle immagini -->
            <xsl:call-template name="cut">
            <xsl:with-param name="imgUrl" select="$imgUrl"/>
            <xsl:with-param name="zone" select="."/>
            </xsl:call-template>
        </xsl:for-each>
        </xsl:if>
    </div>
</xsl:template>

<!-- Template per le note-->
    <xsl:template match="tei:note">
    <!-- aside elemento html per info secondarie come le note-->
    <aside class="note"> 
        <xsl:apply-templates/>
    </aside>
    </xsl:template>

<!-- Template per la bibliografia-->
    <xsl:template match="tei:bibl">
    <div class="bibl">
        <xsl:apply-templates select="tei:title"/>
        <xsl:apply-templates select="tei:author"/>
        <xsl:apply-templates select="tei:pubPlace"/>
        <xsl:apply-templates select="tei:date"/>
    </div>
    </xsl:template>

<!-- Elementi interni alle note-->
<xsl:template match="tei:bibli/tei:title">
    <span class="bibl-title">
        <xsl:apply-templates/>
    </span>
</xsl:template>
<xsl:template match="tei:bibl/tei:author">
    <span class="bibl-author">
        <xsl:apply-templates/>
    </span>
</xsl:template>
<xsl:template match="tei:bibl/tei:persName">
    <span class="bibl-persName">
        <xsl:apply-templates/>
    </span>
</xsl:template>
<xsl:template match="tei:bibl/tei:fornename">
    <span class="bibl-forename">
        <xsl:apply-templates/>
    </span>
</xsl:template>
<xsl:template match="tei:bibl/tei:abbr">
    <span class="bibl-abbr">
        <xsl:apply-templates/>
    </span>
</xsl:template>
<xsl:template match="tei:bibl/tei:expan">
    <span class="bibl-expan">
        <xsl:apply-templates/>
    </span>
</xsl:template>
<xsl:template match="tei:bibl/tei:surname">
    <span class="bibl-surname">
        <xsl:apply-templates/>
    </span>
</xsl:template>
<xsl:template match="tei:bibl/tei:pubPlace">
    <span class="bibl-surname">
        <xsl:apply-templates/>
    </span>
</xsl:template>
<xsl:template match="tei:bibl/tei:date">
    <span class="bibli-date">
        <xsl:apply-templates/>
    </span>
</xsl:template>



<!-- Div-->
<xsl:template match="tei:div">
    <section>
        <xsl:apply-templates/>
    </section>
</xsl:template>

<!-- Head-->
<xsl:template match="tei:head">
    <h2>
        <xsl:apply-templates/>
    </h2>
</xsl:template>

<!-- Paragrafi-->
<xsl:template match="tei:p">
    <p>
        <xsl:apply-templates/>
    </p>
</xsl:template>

<!-- Scelte tra varianti testuali: mostra solo la forma sic-->
<xsl:template match="tei:choice">
    <xsl:apply-templates select="tei:sic"/>
</xsl:template>

<!-- Persone reali -->
<xsl:template match="tei:persName[@type='real']">
    <span class="person-real">
        <xsl:apply-templates/>
    </span>
</xsl:template>

<!-- Personaggi immaginari-->
<xsl:template match="tei:persName[@type=('fictional', 'mythological')]">
    <span class="person-fictional">
        <xsl:apply-templates/>
    </span>
</xsl:template>

<!-- Opere-->
<xsl:template match="tei:title">
    <span class="work">
        <xsl:apply-templates/>
    </span>
</xsl:template>

<!-- Luoghi -->
<xsl:template match="tei:placeName">
    <span class="place">
        <xsl:apply-templates/>
    </span>
</xsl:template>

<!-- Casa editrice/rivista/organizzazioni varie-->
<xsl:template match="tei:orgName">
    <span class="org">
        <xsl:apply-templates/>
    </span>
</xsl:template>

<!-- Date-->
<xsl:template match="tei:date">
    <span class="date">
        <xsl:apply-templates/>
    </span>
</xsl:template>

<!-- Temi-->
<xsl:template match="tei:seg[@ana]">
    <span class="theme">
        <xsl:apply-templates/>
    </span>
</xsl:template>

<!-- Correnti letterarie/artistiche-->
<xsl:template match="tei:term[@type='literaryMovement']">
    <span class="movement">
        <xsl:apply-templates/>
    </span>
</xsl:template>

<!-- Testo in lingua straniera-->
<xsl:template match="tei:foreign">
    <span class="foreign">
        <xsl:apply-templates/>
    </span>
</xsl:template>

<!-- Citazioni-->
<xsl:template match="tei:q">
    <span class="quote">
        <xsl:apply-templates/>
    </span>
</xsl:template>

<!-- Epiteti-->
<xsl:template match="tei:addName[@type='epithet']">
    <span class="epithet">
        <xsl:apply-templates/>
    </span>
</xsl:template>

</xsl:stylesheet> 