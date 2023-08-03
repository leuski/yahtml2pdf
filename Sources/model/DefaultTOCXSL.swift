//
//  DefaultTOCXSL.swift
//  yahtml2pdf
//
//  Created by Anton Leuski on 8/1/23.
//

import Foundation

let defaultTocXsl = """
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:outline="http://wkhtmltopdf.org/outline"
                xmlns="http://www.w3.org/1999/xhtml">
  <xsl:output doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
              indent="yes"/>
  <xsl:param name="lang" select="'en'"/>
  <xsl:param name="style-sheet"/>
  <xsl:param name="title" select="'Table of Contents'"/>
  <xsl:template match="outline:outline">
    <html>
      <xsl:attribute name="lang">
        <xsl:value-of select="$lang"/>
      </xsl:attribute>
      <head>
        <title><xsl:value-of select="$title"/></title>
        <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
        <style>
          .toc * a {
            display: block;
          }

          .toc * .entry {
            page-break-inside: avoid;
            display: grid;
            grid-template-columns: auto max-content;
            grid-template-areas: "chapter page";
            align-items: end;
            gap: 0 .25rem;
          }

          .toc * .chapter {
            grid-area: chapter;
            position: relative;
            overflow: hidden;
          }

          .toc * .chapter::after {
            position: absolute;
            padding-left: .25ch;
            content: " . . . . . . . . . . . . . . . . . . . . . . . . . . . "
            ". . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . "
            ". . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . "
            ". . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ";
            text-align: right;
          }

          .toc * .page {
            grid-area: page;
            font-variant-numeric: tabular-nums;
          }
        </style>
        <xsl:if test="$style-sheet!=''">
          <link rel="stylesheet">
            <xsl:attribute name="href">
              <xsl:value-of select="$style-sheet"/>
            </xsl:attribute>
          </link>
        </xsl:if>
      </head>
      <body class="toc">
        <h1><xsl:value-of select="$title"/></h1>
        <ul>
          <xsl:apply-templates select="outline:item/outline:item"/>
        </ul>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="outline:item">
    <li>
      <xsl:if test="@title!=''">
        <a>
          <xsl:if test="@link">
            <xsl:attribute name="href">
              <xsl:value-of select="@link"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@backLink">
            <xsl:attribute name="id">
              <xsl:value-of select="@backLink"/>
            </xsl:attribute>
          </xsl:if>
          <div class="entry">
              <div class="chapter">
                <xsl:value-of select="@title"/>
              </div>
              <div class="page">
                <xsl:value-of select="@page"/>
              </div>
          </div>
        </a>
      </xsl:if>
      <xsl:if test="*">
        <ul>
          <xsl:apply-templates select="outline:item"/>
        </ul>
      </xsl:if>
    </li>
  </xsl:template>
</xsl:stylesheet>
"""
