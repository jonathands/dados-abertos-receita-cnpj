#!/bin/bash

# Array of file URLs to download and check
files=(
  "https://dadosabertos.rfb.gov.br/CNPJ/Empresas0.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Empresas1.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Empresas2.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Empresas3.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Empresas4.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Empresas5.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Empresas6.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Empresas7.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Empresas8.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Empresas9.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Estabelecimentos0.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Estabelecimentos1.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Estabelecimentos2.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Estabelecimentos3.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Estabelecimentos4.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Estabelecimentos5.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Estabelecimentos6.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Estabelecimentos7.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Estabelecimentos8.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Estabelecimentos9.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/LAYOUT_DADOS_ABERTOS_CNPJ.pdf"
  "https://dadosabertos.rfb.gov.br/CNPJ/Motivos.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Municipios.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Naturezas.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Paises.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Qualificacoes.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Simples.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Socios0.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Socios1.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Socios2.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Socios3.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Socios4.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Socios5.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Socios6.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Socios7.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Socios8.zip"
  "https://dadosabertos.rfb.gov.br/CNPJ/Socios9.zip"
)

download_dir="downloads"
status="success"

mkdir -p "$download_dir"

for file_url in "${files[@]}"; do
  filename=$(basename "$file_url")

  # Check if the file has already been checked
  if [ -f "$download_dir/$filename" ]; then
    echo "Skipping $filename. Already checked."
    continue
  fi

  wget -Pq "$download_dir" "$file_url"

  # Check the integrity of the zip file and verify its contents
  check_zip_file() {
    local file=$1
    local filename=$(basename "$file" .zip)

    if [ ! -f "$file" ]; then
      echo "Error: $file not found."
      return 1
    fi

    if ! unzip -t "$file" >/dev/null; then
      echo "Error: $file is not a valid zip file."
      return 1
    fi

    if ! unzip -l "$file" >/dev/null; then
      echo "Warning: $file does not have any contents."
    else
      echo "Success: $file is a valid zip file with contents."
    fi

    return 0
  }

  # Call the check_zip_file function for the downloaded zip file
  if check_zip_file "$download_dir/$filename"; then
    echo "Checking $filename... Success"
  else
    echo "Checking $filename... Failed. Redownloading..."
    rm "$download_dir/$filename"  # Remove the failed download
    wget -P "$download_dir" "$file_url"  # Redownload the file
    if check_zip_file "$download_dir/$filename"; then # Check again
      echo "Checking $filename... Success"
    else
      echo "Checking $filename... Failed permanently"
      status="failed"
    fi
  fi

  "$download_dir/$filename"
done

if [ "$status" == "success" ]; then
  read "Do you want to make the GH release now? (y/n): " choice

  if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
    bash release-files.sh
  fi
fi

