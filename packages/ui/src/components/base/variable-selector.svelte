<script lang="ts">
    import { Button, FloatingTrigger, Select } from './index.js';
    import type { SelectItem } from '../../types';

    const {
        variableOptions = [],
        onVariableSelect,
        buttonText = '插入变量',
        placeholder = '选择要插入的变量',
        ...rest
    }: {
        variableOptions?: SelectItem[];
        onVariableSelect?: (variable: string) => void;
        buttonText?: string;
        placeholder?: string;
        [key: string]: any;
    } = $props();

    let triggerRef: any;
    let selectedVariable = $state('');

    // 处理变量选择
    const handleVariableSelect = (item: SelectItem) => {
        const variableName = String(item.value);
        selectedVariable = variableName;
        
        // 生成模板语法格式的变量
        const templateVariable = `\${${variableName}}`;
        onVariableSelect?.(templateVariable);
        
        // 关闭下拉菜单
        triggerRef?.hide();
    };

    // 递归渲染变量选项
    const renderVariableOptions = (options: SelectItem[], level = 0): any[] => {
        return options.map(option => ({
            ...option,
            label: typeof option.label === 'string' ? option.label : String(option.label),
            children: option.children ? renderVariableOptions(option.children, level + 1) : undefined
        }));
    };

    const processedOptions = $derived(renderVariableOptions(variableOptions));
</script>

<FloatingTrigger bind:this={triggerRef} placement="bottom-start" {...rest}>
    {#snippet trigger()}
        <Button>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 2C13.1046 2 14 2.89543 14 4V6H16C17.1046 6 18 6.89543 18 8V10H20C21.1046 10 22 10.8954 22 12C22 13.1046 21.1046 14 20 14H18V16C18 17.1046 17.1046 18 16 18H14V20C14 21.1046 13.1046 22 12 22C10.8954 22 10 21.1046 10 20V18H8C6.89543 18 6 17.1046 6 16V14H4C2.89543 14 2 13.1046 2 12C2 10.8954 2.89543 10 4 10H6V8C6 6.89543 6.89543 6 8 6H10V4C10 2.89543 10.8954 2 12 2Z"/>
            </svg>
            {buttonText}
        </Button>
    {/snippet}
    
    {#snippet content()}
        <div class="variable-selector-content">
            <div class="variable-selector-header">
                <span class="variable-selector-title">选择变量</span>
            </div>
            
            {#if processedOptions.length > 0}
                <div class="variable-selector-list">
                    {#each processedOptions as option}
                        <div class="variable-group">
                            <div class="variable-group-title">{option.label}</div>
                            {#if option.children && option.children.length > 0}
                                <div class="variable-group-items">
                                    {#each option.children as child}
                                        <button 
                                            class="variable-item"
                                            onclick={() => handleVariableSelect(child)}
                                            title={`插入变量: \$\{${child.value}\}`}
                                        >
                                            <span class="variable-name">{child.label}</span>
                                            <span class="variable-syntax">{'${' + child.value + '}'}</span>
                                        </button>
                                        
                                        {#if child.children && child.children.length > 0}
                                            <div class="variable-sub-items">
                                                {#each child.children as subChild}
                                                    <button 
                                                        class="variable-item variable-sub-item"
                                                        onclick={() => handleVariableSelect(subChild)}
                                                        title={`插入变量: \$\{${subChild.value}\}`}
                                                    >
                                                        <span class="variable-name">{subChild.label}</span>
                                                        <span class="variable-syntax">{'${' + subChild.value + '}'}</span>
                                                    </button>
                                                {/each}
                                            </div>
                                        {/if}
                                    {/each}
                                </div>
                            {:else}
                                <button 
                                    class="variable-item"
                                    onclick={() => handleVariableSelect(option)}
                                    title={`插入变量: \$\{${option.value}\}`}
                                >
                                    <span class="variable-name">{option.label}</span>
                                    <span class="variable-syntax">{'${' + option.value + '}'}</span>
                                </button>
                            {/if}
                        </div>
                    {/each}
                </div>
            {:else}
                <div class="variable-selector-empty">
                    <span>暂无可用变量</span>
                    <small>请先添加输入参数或连接其他节点</small>
                </div>
            {/if}
        </div>
    {/snippet}
</FloatingTrigger>

<style lang="less">
    .variable-selector-content {
        min-width: 300px;
        max-width: 400px;
        max-height: 400px;
        overflow-y: auto;
        background: #fff;
        border: 1px solid #ccc;
        border-radius: 5px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        z-index: 1000;
    }

    .variable-selector-header {
        padding: 10px 12px;
        border-bottom: 1px solid #eee;
        background: #f8f9fa;
        border-radius: 5px 5px 0 0;
    }

    .variable-selector-title {
        font-size: 14px;
        font-weight: 600;
        color: #333;
    }

    .variable-selector-list {
        padding: 8px 0;
    }

    .variable-group {
        margin-bottom: 8px;
        
        &:last-child {
            margin-bottom: 0;
        }
    }

    .variable-group-title {
        padding: 6px 12px;
        font-size: 12px;
        font-weight: 600;
        color: #666;
        background: #f5f5f5;
        border-bottom: 1px solid #eee;
    }

    .variable-group-items {
        padding: 4px 0;
    }

    .variable-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        width: 100%;
        padding: 8px 12px;
        border: none;
        background: none;
        cursor: pointer;
        font-size: 13px;
        text-align: left;
        transition: background-color 0.2s;

        &:hover {
            background: #f0f8ff;
        }

        &:active {
            background: #e6f3ff;
        }
    }

    .variable-sub-item {
        padding-left: 24px;
        background: #fafafa;
        
        &:hover {
            background: #f0f8ff;
        }
    }

    .variable-sub-items {
        border-left: 2px solid #eee;
        margin-left: 12px;
    }

    .variable-name {
        flex: 1;
        color: #333;
        font-weight: 500;
    }

    .variable-syntax {
        color: #0066cc;
        font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
        font-size: 11px;
        background: #f0f8ff;
        padding: 2px 6px;
        border-radius: 3px;
        margin-left: 8px;
    }

    .variable-selector-empty {
        padding: 20px 12px;
        text-align: center;
        color: #999;
        
        span {
            display: block;
            font-size: 14px;
            margin-bottom: 4px;
        }
        
        small {
            font-size: 12px;
            color: #ccc;
        }
    }
</style>
