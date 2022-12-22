module.exports = function (RED) {

    function tempADC_Node(config) {
        RED.nodes.createNode(this, config);
        var node = this;

        this.on('input', function (msg) {
            if (node.Pin_num <= 0 || node.Pin_num != isNaN) {
                node.warn("Pin�ԍ�������������܂���B������Pin�ԍ�����͂��ĉ������B");
                node.send(msg);
            }
        });
    }
    RED.nodes.registerType("tempADC", tempADC_Node);
}