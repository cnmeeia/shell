
git config --global user.name cnmeeia

git config --global user.email github@app2022.ml

find . -type f -name "*.DS_Store" -delete

git add .

git commit -m "update"

git push -f origin main
