<script lang="ts">
    import { Textarea } from './index.js';
    import CodeEditorToolbar from './code-editor-toolbar.svelte';

    const {
        value = '',
        language = 'javascript',
        placeholder = '请输入代码',
        onchange,
        style = '',
        height = 300,
        theme = 'vs',
        readOnly = false,
        showToolbar = true,
        ...rest
    }: {
        value?: string;
        language?: 'javascript' | 'python' | 'qlexpress';
        placeholder?: string;
        onchange?: (value: string) => void;
        style?: string;
        height?: number;
        theme?: 'vs' | 'vs-dark' | 'hc-black';
        readOnly?: boolean;
        showToolbar?: boolean;
        [key: string]: any;
    } = $props();

    let textareaRef: HTMLTextAreaElement;
    let currentValue = $state(value);
    let currentTheme = $state(theme);
    let showMinimap = $state(false);

    // 计算行数
    const rows = Math.max(10, Math.floor(height / 20));

    // 处理文本变化
    const handleChange = (e: Event) => {
        const target = e.target as HTMLTextAreaElement;
        currentValue = target.value;
        onchange?.(target.value);
    };

    // 响应外部值变化
    $effect(() => {
        if (value !== currentValue) {
            currentValue = value;
            if (textareaRef) {
                textareaRef.value = value;
            }
        }
    });

    // 工具栏事件处理
    const handleFormat = () => {
        // 简单的代码格式化（基于语言）
        if (textareaRef) {
            // 这里可以添加简单的格式化逻辑
            console.log('格式化代码');
        }
    };

    const handleClear = () => {
        if (textareaRef) {
            textareaRef.value = '';
            currentValue = '';
            onchange?.('');
        }
    };

    const handleToggleTheme = () => {
        const themes = ['vs', 'vs-dark', 'hc-black'];
        const currentIndex = themes.indexOf(currentTheme);
        const nextIndex = (currentIndex + 1) % themes.length;
        currentTheme = themes[nextIndex];
    };

    const handleToggleMinimap = () => {
        showMinimap = !showMinimap;
    };

    // 格式化代码的方法
    export const formatCode = () => {
        handleFormat();
    };

    // 获取编辑器实例的方法
    export const getEditor = () => textareaRef;
</script>

<div class="smart-code-editor-container" {style} {...rest}>
    {#if showToolbar}
        <CodeEditorToolbar
            {language}
            theme={currentTheme}
            {showMinimap}
            onFormat={handleFormat}
            onClear={handleClear}
            onToggleTheme={handleToggleTheme}
            onToggleMinimap={handleToggleMinimap}
        />
    {/if}

    <Textarea
        bind:this={textareaRef}
        {rows}
        {placeholder}
        {readOnly}
        class="smart-code-editor nodrag nowheel {showToolbar ? 'with-toolbar' : ''}"
        onchange={handleChange}
        value={currentValue}
    />
</div>

<style>
    .smart-code-editor-container {
        width: 100%;
        border: 1px solid #ccc;
        border-radius: 5px;
        overflow: hidden;
    }

    .smart-code-editor-container:focus-within {
        border-color: var(--tf-primary-color);
        box-shadow: 0 0 5px rgba(81, 203, 238, .2);
    }

    :global(.smart-code-editor) {
        width: 100%;
        font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
        font-size: 14px;
        border: none;
        border-radius: 0;
    }

    :global(.smart-code-editor.with-toolbar) {
        border-top: 1px solid #ccc;
        border-radius: 0 0 5px 5px;
    }
</style>
