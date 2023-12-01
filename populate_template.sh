export ENV_QUESTIONS=$(echo $B64_ENV_QUESTIONS | base64 -d)
envsubst <question_data.yml.tpl > $BASE_FILE_NAME.yml