module.exports = function (RED) {

    function ADC_Node(config) {
        RED.nodes.createNode(this, config);
        var node = this;

        this.on('input', function (msg) {
            if (node.Pin_num <= 0 || node.Pin_num != isNaN) {
                node.warn("Pin番号が正しくありません。正しいPin番号を入力して下さい。");
                node.send(msg);
            }
        });
    }
    RED.nodes.registerType("ADC", ADC_Node);
}