<script lang="ts">
    import NodeWrapper from '../core/NodeWrapper.svelte';
    import { type NodeProps, useSvelteFlow } from '@xyflow/svelte';
    import { Button, Heading } from '../base';
    import { SmartTemplateEditor, VariableSelector } from '../base/index.js';
    import RefParameterList from '../core/RefParameterList.svelte';
    import { getCurrentNodeId } from '../../store/nodeContext';
    import { useAddParameter } from '../utils/useAddParameter';
    import OutputDefList from '../core/OutputDefList.svelte';
    import { useRefOptions } from '../utils/useRefOptions';

    const { data, ...rest }: {
        data: NodeProps['data'],
        [key: string]: any
    } = $props();

    const currentNodeId = getCurrentNodeId();
    const { addParameter } = useAddParameter();
    const { updateNodeData } = useSvelteFlow();

    // 获取可用的变量选项
    const variableOptions = useRefOptions();

    // 模板编辑器引用
    let templateEditor: any;

    // 处理变量插入
    const handleVariableInsert = (variable: string) => {
        if (templateEditor && templateEditor.insertText) {
            templateEditor.insertText(variable);
        } else {
            // 如果编辑器没有 insertText 方法，则追加到当前值
            const currentTemplate = data.template || '';
            updateNodeData(currentNodeId, () => {
                return {
                    template: currentTemplate + variable
                }
            });
        }
    };

    $effect(() => {
        if (!data.outputDefs || data.outputDefs.length === 0) {
            addParameter(currentNodeId, 'outputDefs', {
                name: 'output',
                dataType: 'String',
                dataTypeDisabled: true,
                deleteDisabled: true
            });
        }
    });
</script>


<NodeWrapper {data} {...rest}>

    {#snippet icon()}
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
            <path
                d="M2 4C2 3.44772 2.44772 3 3 3H21C21.5523 3 22 3.44772 22 4V20C22 20.5523 21.5523 21 21 21H3C2.44772 21 2 20.5523 2 20V4ZM4 5V19H20V5H4ZM7 8H17V11H15V10H13V14H14.5V16H9.5V14H11V10H9V11H7V8Z"></path>
        </svg>
    {/snippet}

    <div class="heading">
        <Heading level={3}>输入参数</Heading>
        <Button class="input-btn-more" style="margin-left: auto" onclick={()=>{
            addParameter(currentNodeId)
        }}>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path d="M11 11V5H13V11H19V13H13V19H11V13H5V11H11Z"></path>
            </svg>
        </Button>
    </div>
    <RefParameterList />

    <div class="heading">
        <Heading level={3} mt="10px" mb="10px">模板内容</Heading>
        <VariableSelector
            variableOptions={$variableOptions}
            onVariableSelect={handleVariableInsert}
            buttonText="插入变量"
            style="margin-left: auto"
        />
    </div>

    <div class="setting-item">
        <SmartTemplateEditor
            bind:this={templateEditor}
            rows={10}
            placeholder="请输入模板内容，使用 ${变量名} 引用变量"
            style="width: 100%"
            onchange={(value) => {
                updateNodeData(currentNodeId, () => {
                    return {
                        template: value
                    }
                })
            }}
            value={data.template || ""}
            variableOptions={$variableOptions}
        />
    </div>


    <div class="heading">
        <Heading level={3} mt="10px">输出参数</Heading>
    </div>
    <OutputDefList />

</NodeWrapper>

<style>
    .heading {
        display: flex;
        margin-bottom: 10px;
    }

    .setting-title {
        font-size: 12px;
        color: #999;
        margin-bottom: 4px;
        margin-top: 10px;
    }

    .setting-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 10px;
        gap: 10px;
    }

</style>



