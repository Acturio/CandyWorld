# CandyWorld
AWK, ML model and API project
`curl localhost:3838/prediccio_hd -H "Content-Type: application/json" --request POST --data @data/heart_test.json`

`curl localhost:3838/new_data -H "Content-Type: application/json" --request POST --data @data/heart_test.json`

`curl localhost:3838/re_train -H "Content-Type: application/json" --request POST`

`curl -o plot.png localhost:3838/roc_curve_plot --request GET; xdg-open curva_roc.png`

`curl -o plot.png localhost:3838/pr_curve_plot --request GET; xdg-open pr_plot.png`

`curl localhost:3838/metrics --request GET` 