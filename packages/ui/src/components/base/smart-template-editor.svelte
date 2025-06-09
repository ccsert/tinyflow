<script lang="ts">
    import { Textarea } from './index.js';
    import type { SelectItem } from '../../types';

    const {
        value = '',
        placeholder = '请输入模板内容，使用 ${变量名} 引用变量',
        onchange,
        variableOptions = [],
        style = '',
        rows = 10,
        ...rest
    }: {
        value?: string;
        placeholder?: string;
        onchange?: (value: string) => void;
        variableOptions?: SelectItem[];
        style?: string;
        rows?: number;
        [key: string]: any;
    } = $props();

    let textareaRef: HTMLTextAreaElement;
    let currentValue = $state(value);

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

    // 导出插入文本的方法
    export const insertText = (text: string) => {
        if (textareaRef) {
            const start = textareaRef.selectionStart || 0;
            const end = textareaRef.selectionEnd || 0;
            const currentText = textareaRef.value;
            const newText = currentText.substring(0, start) + text + currentText.substring(end);
            textareaRef.value = newText;
            textareaRef.selectionStart = textareaRef.selectionEnd = start + text.length;
            textareaRef.focus();

            // 触发change事件
            currentValue = newText;
            onchange?.(newText);
        }
    };

    // 导出获取编辑器实例的方法
    export const getEditor = () => textareaRef;
</script>

<Textarea
    bind:this={textareaRef}
    {rows}
    {placeholder}
    {style}
    class="smart-template-editor nodrag nowheel"
    onchange={handleChange}
    value={currentValue}
    {...rest}
/>

<style>
    :global(.smart-template-editor) {
        font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
        font-size: 14px;
    }
</style>
