# AI 偵測系統 (Streamlit)

簡單的 Streamlit 應用程式，用於偵測輸入文字或檔案（PPTX / PDF / 圖片）是否可能是 AI 生成。

快速開始

1. 建議建立並啟用虛擬環境。

2. 安裝相依套件：

```powershell
pip install -r requirements.txt
```

3. 啟動應用程式：

```powershell
streamlit run hw5a.py
```

注意
- `paddleocr` 下載與模型檔案在第一次執行時會額外下載，請確保網路連線。
- 若要使用 `roberta-base-openai-detector` 模型，需要可用的 PyTorch 設定與網路以下載模型權重。

如需協助，回覆我並說明你想要的變更（例如：加入模型選擇器、處理大檔案的進階顯示、或打包成 exe）。