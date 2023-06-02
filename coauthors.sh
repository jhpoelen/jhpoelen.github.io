#!/bin/bash
#
# query wikidata for co-authors.
# based on queries at https://scholia.toolforge.org/author/Q58206618#coauthors
#

preston track "https://query.wikidata.org/sparql?format=json&query=%23%20tool%3A%20scholia%0A%23defaultView%3AGraph%0APREFIX%20target%3A%20%3Chttp%3A%2F%2Fwww.wikidata.org%2Fentity%2FQ58206618%3E%0A%0A%23%20Egocentric%20co-author%20graph%20for%20an%20author%0ASELECT%20%3Fcoauthor%20%3FcoauthorLabel%0AWITH%20%7B%0A%20%20SELECT%20(COUNT(%3Fwork)%20AS%20%3Fcount)%20%3Fcoauthor%20WHERE%20%7B%0A%20%20%20%20%23%20Find%20co-authors%0A%20%20%20%20%3Fwork%20wdt%3AP50%20target%3A%2C%20%3Fcoauthor%0A%0A%20%20%20%20%23%20Filtering%20%0A%20%20%20%20%23%20Only%20journal%20and%20conference%20articles%2C%20books%2C%20not%20(yet%3F)%20software%0A%20%20%20%20%23%20VALUES%20%3Fpublication_type%20%7B%20wd%3AQ13442814%20wd%3AQ571%20wd%3AQ26973022%7D%20%20%0A%20%20%20%20%23%20%3Fwork%20wdt%3AP31%20%3Fpublication_type%20.%0A%20%20%7D%0A%20%20GROUP%20BY%20%3Fcoauthor%20%0A%20%20ORDER%20BY%20DESC(%3Fcount)%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%0A%20%20%23%20Limit%20the%20size%20of%20the%20graph%2C%20to%20avoid%20overburdening%20the%20browser%0A%20%20LIMIT%201000%0A%7D%20AS%20%25authors%0AWITH%20%7B%0A%20%20SELECT%20%3Fcoauthor%20WHERE%20%7B%0A%20%20%20%20INCLUDE%20%25authors%0A%20%20%20%20%0A%20%20%20%20%23%20Exclude%20self-links%0A%20%20%20%20FILTER%20(%3Fcoauthor%20!%3D%20target%3A)%0A%20%20%7D%0A%7D%20AS%20%25result%0AWHERE%20%7B%0A%20%20INCLUDE%20%25result%0A%20%20%23%20Label%20the%20results%20%0A%20%20SERVICE%20wikibase%3Alabel%20%7B%20bd%3AserviceParam%20wikibase%3Alanguage%20%22en%2Cfr%2Cde%2Cru%2Ces%2Czh%2Cjp%22.%20%7D%0A%7D"\
 | grep hasVersion\
 | preston cat\
 | jq --compact-output '.results[][] | { "coauthor": .["coauthorLabel"].value, "coauthorProfile": .["coauthor"].value }'\
 | tee coauthors.json\
 | mlr --ijson --otsvlite cat\
 | tee coauthors.tsv\
 | mlr --itsvlite --ocsv cat\
 | tee coauthors.csv
