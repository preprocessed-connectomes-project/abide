---
layout: page
title: Publications
---

<noscript>
   <!-- bibtex source hidden by default, show it if JS disabled -->
   <style>
      #bibtex { display: block;}
   </style>
</noscript>

<table id="pubTable" class="display"></table>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"></script>
<script type="text/javascript" src="javascripts/bib-list.js"></script>
<script type="text/javascript">
    $(document).ready(function() {
        bibtexify("abide_preproc.bib", "pubTable",{'tweet': 'RCCraddock'});
    });
</script>
