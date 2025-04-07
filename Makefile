.PHONY: ai-rules
ai-rules:
	sh generate-ai-rules.sh

.PHONY: clean-ai-rules
clean-ai-rules:
	rm -rf .github/copilot-instructions.md
	rm -rf .clinerules
	find . -name "CLAUDE.md" -type f -delete

.PHONY: lint-ai-rules
lint-ai-rules:
	@make clean-ai-rules
	claude -p "あなたはリンターです。rules-bank以下のmdファイルがあなたや他のAIコーディングツールに渡す情報として適切かをコードベースと照らし合わせてよく考えて回答してください。"
