#!/bin/bash

download_dir="downloads"

github_repo="jonathands/dados-abertos-receita-cnpj"
github_release_title_prefix=$(date +"%Y.%m")
github_release_message="Release created on $(date)"

# Create the GitHub release and add all files
github_release_title="${github_release_title_prefix}"
gh release create "$github_release_title" --repo "$github_repo" --title "$github_release_title" --notes "$github_release_message"

release_files=()
for file in "$download_dir"/*; do
  if [ -f "$file" ]; then
    gh release upload "$github_release_title" "$file" --repo "$github_repo"

    release_files+=("$(basename "$file")")
  fi
done

# UPDATE README TO HAVE LASTEST RELEASE
release_files_section=$"### Arquivos para Release $github_release_title_prefix\n\n"
for file_url in "${release_files[@]}"; do
  echo $file_url
  release_files_section+="* wget https://github.com/jonathands/dados-abertos-receita-cnpj/releases/download/$github_release_title/$file_url \n"
done

rm -rf README.md
wget https://raw.githubusercontent.com/jonathands/dados-abertos-receita-cnpj/main/README.md

readme_file="README.md"
readme_contents=$(cat "$readme_file")

updated_readme_contents=$"$release_files_section\n\n$readme_contents"


repo_folder="temp_repo"
git clone git@github.com:jonathands/dados-abertos-receita-cnpj.git $repo_folder
cd "$repo_folder"

echo -e "$updated_readme_contents" > "$readme_file"

git add "$readme_file"
git commit -m "Update README.md with release files"
git push origin main

cd ..
rm -rf "$repo_folder"