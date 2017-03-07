# OVERRIDING XSLT FOR XSPEC

Because sometimes xspec doesn't have the expected behaviour we prefer adapting the XSLT by overriding it, rather than changing anything in the original XSLT.

These adaptation may be post as issues on the XSPEC github and then be removed.

One the common adaptation is to simulate a specific xsl:output, because xspec doesn't car about this in the original XSLT.

Doing like this we can continue doing Intergation Test by comparing the result of the original transformation (made by hand when applying the associated transformation Scenario in oXygen)
